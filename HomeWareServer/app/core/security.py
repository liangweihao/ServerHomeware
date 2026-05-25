"""
安全工具模块
提供密码哈希、JWT Token、密码强度校验等安全相关功能
"""
import re
import secrets
import string
from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.config import settings

# 密码上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password: str) -> str:
    """
    对密码进行哈希处理
    :param password: 原始密码
    :return: 哈希后的密码
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    验证密码是否匹配
    :param plain_password: 原始密码
    :param hashed_password: 哈希后的密码
    :return: 是否匹配
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    创建访问令牌
    :param data: 包含用户信息的字典
    :param expires_delta: 过期时间
    :return: JWT令牌
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    创建刷新令牌
    :param data: 包含用户信息的字典
    :param expires_delta: 过期时间
    :return: JWT令牌
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Optional[dict]:
    """
    解码JWT令牌
    :param token: JWT令牌
    :return: 解码后的载荷，如果无效返回None
    """
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except JWTError:
        return None


def validate_password_strength(password: str) -> Tuple[bool, str]:
    """
    验证密码强度
    :param password: 密码
    :return: (是否通过, 错误消息)
    """
    # 检查长度
    if len(password) < 8:
        return False, "密码长度至少需要8位"

    # 检查是否包含字母
    if not re.search(r'[a-zA-Z]', password):
        return False, "密码需要包含字母"

    # 检查是否包含数字
    if not re.search(r'[0-9]', password):
        return False, "密码需要包含数字"

    return True, "密码强度符合要求"


def generate_token(length: int = 32) -> str:
    """
    生成随机token
    :param length: token长度
    :return: 随机token
    """
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def generate_secure_filename(filename: str) -> str:
    """
    生成安全的文件名（去除危险字符）
    :param filename: 原始文件名
    :return: 安全的文件名
    """
    # 去除路径分隔符和特殊字符
    safe_chars = re.sub(r'[^\w\.\-]', '_', filename)
    # 防止路径遍历
    safe_chars = safe_chars.replace('..', '_')
    return safe_chars.strip()
