# HomeStock Server dev mode (Windows PowerShell)
# Usage: .\start-dev.ps1
# Requires: Python 3.10+

$ErrorActionPreference = 'Stop'
$Port = 8000

Write-Host '=========================================='
Write-Host '   HomeStock Server (dev / SQLite)'
Write-Host '=========================================='

if (-not (Test-Path 'app\main.py')) {
    Write-Error 'Run this script inside the HomeWareServer directory.'
}

# Free port 8000
$onPort = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($onPort) {
    $pids = $onPort.OwningProcess | Sort-Object -Unique
    foreach ($pid in $pids) {
        Write-Host "Stopping process $pid on port $Port..."
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error 'Python not found. Install from https://www.python.org/downloads/'
}

if (-not (Test-Path '.venv')) {
    Write-Host 'Creating virtual environment...'
    python -m venv .venv
}

Write-Host 'Activating virtual environment...'
& .\.venv\Scripts\Activate.ps1

$fastapiMarker = Get-ChildItem -Path '.venv\Lib\site-packages\fastapi' -ErrorAction SilentlyContinue
if (-not $fastapiMarker) {
    Write-Host 'Installing dependencies (Tsinghua mirror)...'
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple aioredis aiosqlite
}

$env:PYTHONPATH = "$(Get-Location);$env:PYTHONPATH"

Write-Host 'Writing .env.dev...'
$envContent = @'
APP_NAME=HomeStock
APP_ENV=development
DEBUG=true
API_PREFIX=/api/v1

DATABASE_URL=sqlite+aiosqlite:///./homestock.db

REDIS_URL=redis://localhost:6379/0

JWT_SECRET_KEY=dev-secret-key-for-development-only-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=30

UPLOAD_DIR=./uploads
MAX_FILE_SIZE_MB=10
FCM_SERVER_KEY=

'@
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path (Get-Location) '.env.dev'), $envContent, $utf8NoBom)

$env:ENV_FILE = '.env.dev'

New-Item -ItemType Directory -Force -Path '.\data' | Out-Null
New-Item -ItemType Directory -Force -Path '.\uploads' | Out-Null

Write-Host 'Creating SQLite tables...'
python -c @"
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.core.database import Base
from app.models import *

async def create_tables():
    engine = create_async_engine('sqlite+aiosqlite:///./homestock.db')
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await engine.dispose()
    print('Database tables ready')

asyncio.run(create_tables())
"@

Write-Host ''
Write-Host "Starting server: http://localhost:$Port"
Write-Host "API docs:        http://localhost:$Port/docs"
Write-Host ''

uvicorn app.main:app --host 0.0.0.0 --port $Port --reload
