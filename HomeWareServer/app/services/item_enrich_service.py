"""
物品草稿 AI 增强服务
入库页「魔法备注」：根据已填信息生成口语化备注 + 检索别名。
"""
from __future__ import annotations

import json
import logging
import re
from typing import Any, Dict, List, Optional

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

_MAX_ALIASES = 8
_MAX_NOTES_CHARS = 120


def _parse_json_object(raw: str) -> Dict[str, Any]:
    """从模型输出中提取 JSON 对象。"""
    text = (raw or "").strip()
    if not text:
        return {}
    try:
        start = text.find("{")
        end = text.rfind("}") + 1
        if start >= 0 and end > start:
            return json.loads(text[start:end])
    except (json.JSONDecodeError, ValueError) as e:
        logger.warning("[ItemEnrich] WARN: JSON 解析失败 err=%s raw=%s", e, text[:200])
    return {}


def _fallback_enrich(name: str, brand: Optional[str], category_name: Optional[str]) -> Dict[str, Any]:
    """无 API Key / 调用失败时的本地降级。"""
    bits = [p for p in [brand, name] if p]
    notes = "、".join(bits) if bits else name
    if category_name:
        notes = f"{notes}（{category_name}）"
    aliases: List[str] = []
    if name and len(name) >= 2:
        # 去掉常见品牌前缀后的短名也作为别名候选
        aliases.append(name)
        if brand and name.startswith(brand) and len(name) > len(brand):
            aliases.append(name[len(brand):].strip() or name)
    if category_name:
        aliases.append(category_name)
    # 去重保序
    seen = set()
    uniq = []
    for a in aliases:
        a = a.strip()
        if a and a not in seen:
            seen.add(a)
            uniq.append(a)
    return {
        "notes": notes[:_MAX_NOTES_CHARS],
        "search_aliases": uniq[:_MAX_ALIASES],
    }


class ItemEnrichService:
    """根据表单草稿生成备注与检索别名"""

    def is_configured(self) -> bool:
        return bool(settings.DEEPSEEK_API_KEY and settings.DEEPSEEK_API_KEY.startswith("sk-"))

    async def enrich_draft(
        self,
        *,
        name: str,
        brand: Optional[str] = None,
        category_name: Optional[str] = None,
        specification: Optional[str] = None,
        existing_notes: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        返回 {"notes": str, "search_aliases": List[str]}。
        """
        name = (name or "").strip()
        if not name:
            logger.warning("[ItemEnrich] WARN: 名称为空，无法增强")
            return {"notes": "", "search_aliases": []}

        if not self.is_configured():
            logger.info("[ItemEnrich] INFO: 未配置 DeepSeek，使用降级规则")
            return _fallback_enrich(name, brand, category_name)

        prompt = f"""你是家庭物品管家。根据用户已填写的入库信息，生成：
1) notes：一句口语化中文备注（不超过{_MAX_NOTES_CHARS}字），帮助用户记住这是什么、怎么用/存放；不要编造用户未提供的过期日或价格。
2) search_aliases：3～{_MAX_ALIASES} 个中文检索别名/俗称/品类词，便于以后用「护肤霜」这类日常说法搜到「精华露」。
   - 必须相关，不要塞无关宽词（如「东西」「用品」）
   - 可含品类（护肤、精华）、俗称（面霜、乳液）与用途词（保湿）
   - 不要重复物品全名本身超过 1 次

已填信息：
- 名称: {name}
- 品牌: {brand or "未填"}
- 分类: {category_name or "未填"}
- 规格: {specification or "未填"}
- 现有备注: {existing_notes or "无"}

严格只返回 JSON：
{{"notes":"...","search_aliases":["...","..."]}}
"""
        try:
            raw = await self._call_deepseek(prompt)
            data = _parse_json_object(raw or "")
            notes = str(data.get("notes") or "").strip()
            aliases_raw = data.get("search_aliases") or []
            aliases: List[str] = []
            if isinstance(aliases_raw, list):
                for a in aliases_raw:
                    s = str(a).strip()
                    if s and s not in aliases:
                        aliases.append(s)
            if not notes:
                fb = _fallback_enrich(name, brand, category_name)
                notes = fb["notes"]
            if not aliases:
                aliases = _fallback_enrich(name, brand, category_name)["search_aliases"]
            result = {
                "notes": notes[:_MAX_NOTES_CHARS],
                "search_aliases": aliases[:_MAX_ALIASES],
            }
            logger.info(
                "[ItemEnrich] INFO: 生成成功 name=%s aliases=%s",
                name,
                result["search_aliases"],
            )
            return result
        except Exception as e:
            logger.error("[ItemEnrich] ERROR: 生成失败 %s", e)
            return _fallback_enrich(name, brand, category_name)

    async def _call_deepseek(self, prompt: str) -> Optional[str]:
        url = f"{settings.DEEPSEEK_BASE_URL}/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.DEEPSEEK_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": settings.DEEPSEEK_MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 400,
            "temperature": 0.4,
        }
        timeout = getattr(settings, "DEEPSEEK_TIMEOUT_SECONDS", 30)
        async with httpx.AsyncClient(timeout=timeout, trust_env=False) as client:
            resp = await client.post(url, headers=headers, json=payload)
            resp.raise_for_status()
            return resp.json()["choices"][0]["message"]["content"]


def aliases_to_storage(aliases: Optional[List[str]]) -> Optional[str]:
    """List → DB Text（JSON）。"""
    if not aliases:
        return None
    cleaned = []
    seen = set()
    for a in aliases:
        s = str(a).strip()
        if s and s not in seen:
            seen.add(s)
            cleaned.append(s)
    if not cleaned:
        return None
    return json.dumps(cleaned[:_MAX_ALIASES], ensure_ascii=False)


def aliases_from_storage(raw: Optional[str]) -> List[str]:
    """DB Text → List。"""
    if not raw:
        return []
    text = raw.strip()
    if not text:
        return []
    try:
        data = json.loads(text)
        if isinstance(data, list):
            return [str(x).strip() for x in data if str(x).strip()]
    except (json.JSONDecodeError, TypeError):
        pass
    # 兼容逗号分隔
    return [p.strip() for p in re.split(r"[,，、]", text) if p.strip()]
