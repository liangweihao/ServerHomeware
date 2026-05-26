"""创建测试用户"""
from app.core.database import async_session_maker
from app.models.user import User
from passlib.context import CryptContext
import asyncio

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def create_test_user():
    async with async_session_maker() as session:
        from sqlalchemy import select
        
        # 检查用户是否已存在
        result = await session.execute(select(User).filter(User.phone == '18311026972'))
        user = result.scalar_one_or_none()
        
        if user:
            print('用户已存在')
            return
        
        # 创建测试用户
        hashed_password = pwd_context.hash('123456')
        user = User(
            phone='18311026972',
            password_hash=hashed_password,
            nickname='测试用户',
            is_active=True
        )
        session.add(user)
        await session.commit()
        print('测试用户创建成功')

if __name__ == '__main__':
    asyncio.run(create_test_user())