"""
LLM 服务模块
封装 DeepSeek API 调用，提供家庭助手的意图识别、Function Calling 执行和回复生成。
遵循规则优先 + LLM 兜底策略，未配置 API Key 时优雅降级。
"""
import json
import logging
import re
from typing import Any, Dict, List, Optional

import httpx
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.repositories.item_repo import ItemRepository
from app.repositories.shopping_repo import ShoppingItemRepository

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# 工具定义（Function Calling）
# ──────────────────────────────────────────────
_TOOLS: List[Dict] = [
    {
        "type": "function",
        "function": {
            "name": "query_item_stock",
            "description": (
                "查询家里与关键词相关的物品库存和位置。"
                "用户说「想吃肉/有没有吃的」等泛化需求时，item_name 填「肉」等大类词，"
                "不要臆测「肉松/猪肉」等具体品名；用户明确说「金针菇在哪」时才填具体名称。"
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "item_name": {
                        "type": "string",
                        "description": "搜索关键词或具体物品名，支持模糊匹配",
                    },
                },
                "required": ["item_name"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "query_items_by_category",
            "description": "查询某一类物品（如所有调料、所有药品、所有清洁用品）",
            "parameters": {
                "type": "object",
                "properties": {
                    "category_keyword": {"type": "string", "description": "分类关键词"},
                },
                "required": ["category_keyword"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "check_ingredients_availability",
            "description": "对比一组食材/物品清单与家庭库存，返回有/缺/不足的分类结果",
            "parameters": {
                "type": "object",
                "properties": {
                    "items": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "需要检查的物品名称列表",
                    },
                },
                "required": ["items"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "add_to_shopping_list",
            "description": "将缺少的物品加入购物清单",
            "parameters": {
                "type": "object",
                "properties": {
                    "items": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "要加入购物清单的物品名称列表",
                    },
                },
                "required": ["items"],
            },
        },
    },
]

# 泛化饮食/库存意图关键词：用户未指定具体品名时，应用此词搜索而非臆测品名
_BROAD_INVENTORY_KEYWORDS = frozenset({
    "肉", "菜", "水果", "零食", "药", "药品", "饮料", "吃", "食材", "调料",
})

# ──────────────────────────────────────────────
# 系统提示词
# ──────────────────────────────────────────────
_SYSTEM_PROMPT = """你是「管管」，一个家庭物品助手。你了解这个家庭的所有库存情况。

你的职责：
1. 帮用户查找物品位置和库存
2. 根据用户需求（做某道菜/处理某种情况）判断需要哪些物品，并查询家里有没有
3. 帮用户把缺少的物品加入购物清单

规则：
- 回复简洁，不超过100字
- 涉及库存查询时必须先调用工具，不能凭空捏造数量、品名或位置
- 工具返回 found=false 或 items 为空时，明确说家里没有，不得猜测「可能有xxx」
- 位置信息只能引用工具返回的 location 字段；若为「未指定位置」则如实说明，禁止编造「可能在零食柜/冰箱附近」等
- 用户说「想吃肉/想吃点什么」等泛化需求时：用关键词「肉」调用 query_item_stock，列出工具返回的全部物品；禁止未查库就假定是「肉松/猪肉」等具体品名
- 工具返回多项时须全部列出或概括说明；仅一项时也要与工具 name 字段完全一致
- 仅对家里真实库存物品使用 **加粗**；购物清单、调料列表不要用 ** 包裹，也不要写「购物清单已有：xxx」
- 提到具体库存物品时须调用 query_item_stock，以便 App 展示可跳转卡片
- 工具会先查服务端库存，若无结果会使用客户端同步的本地库存快照
- 主动询问用户是否要把缺少的物品加入购物清单
- 使用中文，语气亲切自然
- 如果不确定用户意图，直接问清楚
"""


def _score_item_name_match(name: str, keyword: str) -> int:
    """
    物品名与关键词匹配得分（越高越相关）。
    100=完全一致；90=名称以关键词开头；70=关键词以名称开头；
    60=名称包含关键词；单字关键词降权为 35，避免「肉」误命中过多条目。
    """
    n = name.strip().lower()
    k = keyword.strip().lower()
    if not n or not k:
        return 0
    if n == k:
        return 100
    if n.startswith(k):
        return 90
    if k.startswith(n) and len(n) >= 2:
        return 70
    if k in n:
        return 35 if len(k) <= 1 else 60
    return 0


class LlmService:
    """DeepSeek LLM 服务，处理家庭助手的智能对话"""

    def __init__(
        self,
        db: AsyncSession,
        family_id: int,
        user_id: int,
        local_items: Optional[List[Dict[str, Any]]] = None,
    ):
        self.db = db
        self.family_id = family_id
        self.user_id = user_id
        self._local_items = local_items or []
        self._item_repo = ItemRepository(db)
        self._shopping_repo = ShoppingItemRepository(db)
        if self._local_items:
            logger.info(
                "[LlmService] INFO: 收到本地库存快照 count=%d",
                len(self._local_items),
            )

    @property
    def _is_configured(self) -> bool:
        """检查是否配置了 API Key"""
        return bool(settings.DEEPSEEK_API_KEY and settings.DEEPSEEK_API_KEY.startswith("sk-"))

    async def chat(
        self,
        user_message: str,
        history: Optional[List[Dict[str, str]]] = None,
    ) -> Dict[str, Any]:
        """
        多轮对话入口
        :param user_message: 用户当前消息
        :param history: 历史消息列表 [{"role": "user"/"assistant", "content": "..."}]
        :return: {"text": str, "action": Optional[str], "shopping_added": List[str]}
        """
        if not self._is_configured:
            logger.warning("[LlmService] WARN: DEEPSEEK_API_KEY 未配置，返回降级提示")
            return {
                "text": "AI 助手功能暂未开启，请联系管理员配置。",
                "action": None,
                "shopping_added": [],
                "items": [],
            }

        # 截断历史，保留最近 N 轮
        max_turns = settings.DEEPSEEK_MAX_HISTORY_TURNS
        if history and len(history) > max_turns * 2:
            history = history[-(max_turns * 2):]

        messages = [{"role": "system", "content": _SYSTEM_PROMPT}]
        if history:
            messages.extend(history)
        messages.append({"role": "user", "content": user_message})

        logger.info("[LlmService] INFO: family=%d 开始对话 msg_len=%d", self.family_id, len(user_message))

        shopping_added: List[str] = []
        referenced_items: List[Dict[str, Any]] = []

        # Function Calling 循环（最多 3 轮工具调用，防止死循环）
        for _round in range(3):
            response = await self._call_api(messages)
            if response is None:
                return {
                    "text": "抱歉，AI 助手暂时无法响应，请稍后再试。",
                    "action": None,
                    "shopping_added": [],
                    "items": self._build_client_items(referenced_items),
                }

            choice = response["choices"][0]
            finish_reason = choice.get("finish_reason")
            msg = choice["message"]

            # 没有工具调用，直接返回文本
            if finish_reason != "tool_calls" or not msg.get("tool_calls"):
                text = msg.get("content") or ""
                await self._enrich_items_from_reply(text, referenced_items)
                logger.info(
                    "[LlmService] INFO: 对话完成 finish_reason=%s reply=%s items=%d",
                    finish_reason,
                    text[:500],
                    len(referenced_items),
                )
                return {
                    "text": text,
                    "action": None,
                    "shopping_added": shopping_added,
                    "items": self._build_client_items(referenced_items),
                }

            # 执行工具调用
            messages.append(msg)
            for tool_call in msg["tool_calls"]:
                fn_name = tool_call["function"]["name"]
                fn_args = json.loads(tool_call["function"]["arguments"] or "{}")
                logger.info("[LlmService] INFO: 调用工具 %s args=%s", fn_name, fn_args)

                tool_result = await self._execute_tool(fn_name, fn_args, shopping_added)
                self._track_tool_items(fn_name, tool_result, referenced_items)
                logger.info(
                    "[LlmService] INFO: 工具 %s 结果摘要 %s",
                    fn_name,
                    json.dumps(tool_result, ensure_ascii=False)[:400],
                )
                messages.append({
                    "role": "tool",
                    "tool_call_id": tool_call["id"],
                    "content": json.dumps(tool_result, ensure_ascii=False),
                })

        logger.warning("[LlmService] WARN: 工具调用超过最大轮数，强制结束")
        return {
            "text": "处理中遇到问题，请换个方式描述一下。",
            "action": None,
            "shopping_added": shopping_added,
            "items": self._build_client_items(referenced_items),
        }

    def _is_non_inventory_bold(self, segment: str) -> bool:
        """购物清单 / 多品名列举 — 不应生成物品卡片或可点追问"""
        if "购物清单" in segment:
            return True
        if segment.endswith("：") or segment.endswith(":"):
            return True
        sep_count = segment.count("、") + segment.count("，") + segment.count(",")
        if sep_count >= 2:
            return True
        if len(segment) > 24 and sep_count >= 1:
            return True
        return False

    def _normalize_display_name(self, segment: str) -> str:
        """去掉括号备注，如 十斤羊肉（未指定位置）"""
        s = re.sub(r"（[^）]*）", "", segment)
        s = re.sub(r"\([^)]*\)", "", s)
        return s.strip()

    async def _enrich_items_from_reply(
        self,
        reply_text: str,
        referenced_items: List[Dict[str, Any]],
    ) -> None:
        """从回复 **加粗** 中识别库存物品，补全可跳转卡片（LLM 未调工具时兜底）"""
        if "**" not in reply_text:
            return
        parts = reply_text.split("**")
        seen_names = {str(i.get("name") or "").lower() for i in referenced_items}
        for i in range(1, len(parts), 2):
            segment = parts[i].strip()
            if self._is_non_inventory_bold(segment):
                continue
            keyword = self._normalize_display_name(segment)
            if len(keyword) < 2 or keyword.lower() in seen_names:
                continue
            stock = await self._tool_query_item_stock(keyword)
            if not stock.get("found") or not stock.get("items"):
                continue
            hit = stock["items"][0]
            hit_name = str(hit.get("name") or keyword).lower()
            if hit_name in seen_names:
                continue
            self._append_referenced_items([hit], referenced_items)
            seen_names.add(hit_name)
            logger.info(
                "[LlmService] INFO: 回复正文补全物品卡片 keyword=%s name=%s",
                keyword,
                hit.get("name"),
            )

    def _lookup_snapshot_by_name(self, name: str) -> Optional[Dict[str, Any]]:
        """在客户端快照中按名称精确查找（用于补全 local_id / item_id）"""
        key = name.strip().lower()
        if not key:
            return None
        for raw in self._local_items:
            if str(raw.get("name") or "").strip().lower() == key:
                return raw
        return None

    def _track_tool_items(
        self,
        fn_name: str,
        result: Dict[str, Any],
        referenced_items: List[Dict[str, Any]],
    ) -> None:
        """从工具结果中提取本轮命中的物品，供客户端展示可点击卡片"""
        if fn_name in ("query_item_stock", "query_items_by_category"):
            if result.get("found") and result.get("items"):
                self._append_referenced_items(result["items"], referenced_items)
        elif fn_name == "check_ingredients_availability":
            for bucket in ("have", "low_stock"):
                for entry in result.get(bucket, []):
                    if isinstance(entry, dict) and entry.get("name"):
                        self._append_referenced_items([entry], referenced_items)

    def _append_referenced_items(
        self,
        items: List[Dict[str, Any]],
        referenced_items: List[Dict[str, Any]],
    ) -> None:
        """去重追加引用物品（同名保留首次）"""
        seen = {str(i.get("name") or "").strip().lower() for i in referenced_items}
        for item in items:
            name = str(item.get("name") or "").strip()
            if not name:
                continue
            name_key = name.lower()
            if name_key in seen:
                continue
            seen.add(name_key)

            local_id = item.get("local_id")
            item_id = item.get("item_id")
            location = item.get("location")
            if (not local_id and not item_id) or not location:
                snap = self._lookup_snapshot_by_name(name)
                if snap:
                    local_id = local_id or snap.get("local_id")
                    item_id = item_id or snap.get("server_item_id")
                    location = location or snap.get("location")

            referenced_items.append({
                "name": name,
                "quantity": item.get("quantity"),
                "unit": item.get("unit") or "个",
                "location": location or "未指定位置",
                "local_id": local_id,
                "item_id": item_id,
            })

    def _build_client_items(self, referenced_items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """组装客户端可点击物品卡片"""
        cards: List[Dict[str, Any]] = []
        for item in referenced_items:
            qty = item.get("quantity")
            unit = item.get("unit") or "个"
            loc = item.get("location") or "未指定位置"
            if qty is not None:
                qty_text = int(qty) if float(qty).is_integer() else float(qty)
                subtitle = f"{loc} · {qty_text}{unit}"
            else:
                subtitle = loc
            cards.append({
                "item_id": item.get("item_id"),
                "local_id": item.get("local_id"),
                "name": item["name"],
                "subtitle": subtitle,
            })
        return cards

    # ──────────────────────────────────────────────
    # 工具执行
    # ──────────────────────────────────────────────

    async def _execute_tool(
        self,
        fn_name: str,
        fn_args: Dict,
        shopping_added: List[str],
    ) -> Dict:
        """分发并执行工具调用，返回结果字典"""
        try:
            if fn_name == "query_item_stock":
                return await self._tool_query_item_stock(fn_args["item_name"])
            elif fn_name == "query_items_by_category":
                return await self._tool_query_items_by_category(fn_args["category_keyword"])
            elif fn_name == "check_ingredients_availability":
                return await self._tool_check_ingredients(fn_args["items"])
            elif fn_name == "add_to_shopping_list":
                result = await self._tool_add_to_shopping_list(fn_args["items"])
                shopping_added.extend(fn_args["items"])
                return result
            else:
                logger.warning("[LlmService] WARN: 未知工具 %s", fn_name)
                return {"error": f"未知工具: {fn_name}"}
        except Exception as e:
            logger.error("[LlmService] ERROR: 工具 %s 执行失败: %s", fn_name, e)
            return {"error": str(e)}

    async def _tool_query_item_stock(self, item_name: str) -> Dict:
        """查询物品库存（服务端 DB → 本地快照兜底，按相关度排序）"""
        keyword = item_name.strip()
        is_broad = len(keyword) <= 1 or keyword in _BROAD_INVENTORY_KEYWORDS
        limit = 10 if is_broad else 5

        server_rows = await self._item_repo.search_by_name(self.family_id, keyword, limit=20)
        server_items = [
            {
                "item_id": item.id,
                "name": item.name,
                "quantity": float(item.current_quantity),
                "unit": item.unit or "个",
                "location": item.location.full_path if item.location else "未指定位置",
                "status": "正常" if item.status == 0 else "已用完",
                "source": "server",
            }
            for item in server_rows
            if float(item.current_quantity) > 0
        ]

        local_items = self._search_local_items(keyword, limit=20)
        merged = self._merge_item_results(server_items, local_items)
        ranked = self._rank_item_results(merged, keyword, limit=limit)

        if ranked:
            logger.info(
                "[LlmService] INFO: 库存命中 keyword=%s broad=%s count=%d names=%s",
                keyword,
                is_broad,
                len(ranked),
                [i["name"] for i in ranked],
            )
            payload: Dict[str, Any] = {"found": True, "items": ranked}
            if is_broad:
                payload["broad_search"] = True
                payload["hint"] = "以下为名称含关键词的全部有效库存，请完整告知用户或说明没有相关物品"
            return payload

        return {"found": False, "message": f"家里没有找到与「{keyword}」相关的物品"}

    def _merge_item_results(
        self,
        primary: List[Dict],
        secondary: List[Dict],
    ) -> List[Dict]:
        """合并服务端与本地结果，同名去重（优先保留服务端）"""
        seen: set[str] = set()
        merged: List[Dict] = []
        for item in primary + secondary:
            name_key = str(item.get("name") or "").strip().lower()
            if not name_key or name_key in seen:
                continue
            seen.add(name_key)
            merged.append(item)
        return merged

    def _rank_item_results(
        self,
        items: List[Dict],
        keyword: str,
        limit: int,
    ) -> List[Dict]:
        """按匹配得分排序并过滤低相关度结果"""
        min_score = 35 if len(keyword.strip()) <= 2 or keyword in _BROAD_INVENTORY_KEYWORDS else 50
        scored: List[tuple[int, Dict]] = []
        for item in items:
            name = str(item.get("name") or "")
            score = _score_item_name_match(name, keyword)
            if score >= min_score and float(item.get("quantity") or 0) > 0:
                scored.append((score, item))
        scored.sort(key=lambda pair: (-pair[0], len(pair[1].get("name", ""))))
        return [item for _, item in scored[:limit]]

    async def _tool_query_items_by_category(self, category_keyword: str) -> Dict:
        """按分类关键词查询物品（服务端 DB → 本地快照名称兜底）"""
        keyword = category_keyword.strip()
        items = await self._item_repo.search_by_category_keyword(
            self.family_id, keyword, limit=20
        )
        results = [
            {
                "item_id": i.id,
                "name": i.name,
                "quantity": float(i.current_quantity),
                "unit": i.unit or "个",
                "location": i.location.full_path if i.location else "未指定位置",
                "source": "server",
            }
            for i in items
            if float(i.current_quantity) > 0
        ]

        if not results and self._local_items:
            local = self._search_local_items(keyword, limit=20)
            results = self._merge_item_results([], local)
            if results:
                logger.info(
                    "[LlmService] INFO: 分类查询走本地快照 keyword=%s count=%d",
                    keyword,
                    len(results),
                )

        if not results:
            return {"found": False, "message": f"没有找到「{keyword}」相关的物品"}

        return {"found": True, "count": len(results), "items": results}

    async def _tool_check_ingredients(self, items: List[str]) -> Dict:
        """批量检查物品库存状态（服务端 DB → 本地快照兜底）"""
        have, missing, low = [], [], []
        for name in items:
            found = await self._item_repo.search_by_name(self.family_id, name, limit=1)
            if found:
                item = found[0]
                if item.current_quantity <= 0:
                    missing.append(name)
                elif item.safety_stock and item.current_quantity <= item.safety_stock:
                    low.append({
                        "item_id": item.id,
                        "name": name,
                        "quantity": float(item.current_quantity),
                        "unit": item.unit or "个",
                        "location": item.location.full_path if item.location else "未指定位置",
                    })
                else:
                    have.append({
                        "item_id": item.id,
                        "name": name,
                        "quantity": float(item.current_quantity),
                        "unit": item.unit or "个",
                        "location": item.location.full_path if item.location else "未指定位置",
                    })
                continue

            local = self._search_local_items(name, limit=1)
            if local:
                entry = local[0]
                qty = float(entry.get("quantity") or 0)
                if qty <= 0:
                    missing.append(name)
                else:
                    have.append({
                        "local_id": entry.get("local_id"),
                        "item_id": entry.get("item_id"),
                        "name": entry.get("name") or name,
                        "quantity": qty,
                        "unit": entry.get("unit") or "个",
                        "location": entry.get("location") or "未指定位置",
                    })
            else:
                missing.append(name)

        return {"have": have, "missing": missing, "low_stock": low}

    def _search_local_items(self, keyword: str, limit: int = 5) -> List[Dict]:
        """在客户端上传的本地库存快照中按相关度匹配（仅 quantity>0）"""
        if not self._local_items:
            return []
        key = keyword.strip()
        if not key:
            return []

        ranked = self._rank_item_results(
            [
                {
                    "local_id": raw.get("local_id"),
                    "item_id": raw.get("server_item_id"),
                    "name": str(raw.get("name") or ""),
                    "quantity": float(raw.get("quantity") or 0),
                    "unit": raw.get("unit") or "个",
                    "location": raw.get("location") or "未指定位置",
                    "source": "local_snapshot",
                }
                for raw in self._local_items
            ],
            key,
            limit=limit,
        )
        return ranked

    async def _tool_add_to_shopping_list(self, items: List[str]) -> Dict:
        """批量加入购物清单"""
        added = []
        for name in items:
            try:
                await self._shopping_repo.create({
                    "family_id": self.family_id,
                    "name": name,
                    "quantity": 1,
                    "unit": "个",
                    "created_by": self.user_id,
                    "is_auto_generated": True,
                })
                added.append(name)
            except Exception as e:
                logger.warning("[LlmService] WARN: 加入购物清单失败 name=%s err=%s", name, e)

        logger.info("[LlmService] INFO: 购物清单新增 %d 项", len(added))
        return {"added": added, "count": len(added)}

    # ──────────────────────────────────────────────
    # HTTP 调用
    # ──────────────────────────────────────────────

    async def _call_api(self, messages: List[Dict]) -> Optional[Dict]:
        """调用 DeepSeek API（OpenAI 兼容接口）"""
        url = f"{settings.DEEPSEEK_BASE_URL}/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.DEEPSEEK_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": settings.DEEPSEEK_MODEL,
            "messages": messages,
            "tools": _TOOLS,
            "tool_choice": "auto",
            "max_tokens": 512,
            "temperature": 0.3,
        }

        try:
            async with httpx.AsyncClient(timeout=settings.DEEPSEEK_TIMEOUT_SECONDS) as client:
                resp = await client.post(url, headers=headers, json=payload)
                resp.raise_for_status()
                return resp.json()
        except httpx.TimeoutException:
            logger.error("[LlmService] ERROR: DeepSeek API 请求超时 (%ds)", settings.DEEPSEEK_TIMEOUT_SECONDS)
            return None
        except httpx.HTTPStatusError as e:
            logger.error("[LlmService] ERROR: DeepSeek API HTTP 错误 status=%d body=%s", e.response.status_code, e.response.text[:200])
            return None
        except Exception as e:
            logger.error("[LlmService] ERROR: DeepSeek API 调用异常: %s", e)
            return None
