# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HomeStock (家庭物品管家) — a household inventory management system with a FastAPI backend and Flutter client. Tracks items, expiry dates, stock levels, shopping lists, and usage records across family-shared locations.

**Documentation index**: [`doc/README.md`](doc/README.md) (product, design, client/server architecture). Living API deltas: [`lwh/code_changed/`](lwh/code_changed/). Historical Phase specs are archived under `doc/archive/` — do not treat as source of truth.

## Repository Layout

```
HomeWareServer/   # Python FastAPI backend (port 8000, prefix /api/v1)
HomeWareClient/   # Flutter mobile/desktop client
```

## Backend (HomeWareServer)

### Stack

- **Framework**: FastAPI with uvicorn
- **ORM**: SQLAlchemy 2.0 (async) — supports PostgreSQL (production) and SQLite (development)
- **Auth**: JWT (python-jose, passlib pbkdf2_sha256)
- **Async tasks**: Celery with Redis broker
- **Migrations**: Alembic
- **Rate limiting**: slowapi (optional, degrades gracefully if unavailable)

### Quick Start

```bash
cd HomeWareServer

# Development mode (SQLite, no PostgreSQL/Redis needed):
./start-dev.sh          # macOS/Linux/Git Bash
# or on Windows:
.\start-dev.ps1

# Production (requires PostgreSQL + Redis via Docker):
./start-docker.sh
```

### Commands

```bash
# Run server directly (from HomeWareServer/, with venv active):
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Run database migrations:
alembic upgrade head

# Generate a new migration:
alembic revision --autogenerate -m "description"

# Install dependencies:
pip install -r requirements.txt

# Create test user:
python scripts/create_test_user.py
```

### Architecture: Three-Layer Pattern

```
app/
  api/v1/        # Route handlers — thin, delegate to services
  services/      # Business logic
  repositories/  # Data access (SQLAlchemy queries)
  models/        # SQLAlchemy ORM models
  core/          # Cross-cutting: database, security, deps, middleware, config
```

**Route → Service → Repository flow**: Route handlers receive requests, call services for business logic, services use repositories for DB access. Never put business logic in routes or SQL queries in services.

**Dependency injection chain** (`core/dependencies.py`):
- `get_current_user` — extracts and validates JWT from Bearer token
- `get_current_family` — resolves user's current family
- `require_member` → `require_admin` → `require_owner` — cascading role checks

**Database**: Dual-mode (`core/database.py`). Set `DATABASE_URL` in `.env` to switch between PostgreSQL and SQLite. Development uses `.env.dev` with `ENV_FILE=.env.dev`.

**Config** (`config.py`): pydantic-settings reads from `.env` (or `ENV_FILE` override). Key settings: `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET_KEY`, `UPLOAD_DIR`.

**API response format** (uniform across all endpoints):
```json
{"code": 200, "message": "success", "data": {...}}
```

### Docker Services (docker-compose.yml)

`app` (FastAPI), `db` (PostgreSQL 15), `redis` (Redis 7), `celery_worker`, `celery_beat`. Production compose adds `nginx` reverse proxy with health checks.

## Frontend (HomeWareClient)

### Stack

- **State management**: flutter_riverpod
- **Routing**: go_router (ShellRoute for tab bar, CustomTransitionPage for animations)
- **Local DB**: Drift (SQLite via drift_sqflite) — stores categories, locations, items, usage records, shopping list, family members
- **Code generation**: freezed (immutable models), json_annotation (serialization), drift_dev (DB code)
- **HTTP**: `http` package with JWT stored in SharedPreferences

### Quick Start

```powershell
cd HomeWareClient

# Initialize environment (generates config/env.local.json, runs pub get + code gen):
.\scripts\setup_env.ps1                # localhost
.\scripts\setup_env.ps1 -Platform android   # Android emulator (10.0.2.2)
.\scripts\setup_env.ps1 -Platform device    # physical device (auto-detect IP)

# Run in development:
.\scripts\run_dev.ps1                  # default device
.\scripts\run_dev.ps1 -Device windows
.\scripts\run_dev.ps1 -Device chrome
```

### Commands

```bash
# Code generation (after modifying Drift tables, Freezed models, or JSON annotations):
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation:
dart run build_runner watch --delete-conflicting-outputs

# Run Flutter analyzer:
flutter analyze

# Run tests:
flutter test
```

### Architecture

```
lib/
  main.dart                  # App entry: DB init, notifications, ProviderScope
  core/
    config/app_env.dart      # Reads API_BASE_URL from env.local.json or --dart-define
    constants/               # Colors, typography, spacing, shadows, radius
    exceptions/              # Custom exception classes
    providers/               # Riverpod providers (auth, items, search, shopping, etc.)
    router/app_router.dart   # GoRouter config with all routes
    services/                # API service layer (auth, items, family, upload, etc.)
    theme/                   # AppTheme with light theme
    utils/                   # Image storage utilities
  data/database/             # Drift DB definition (app_database.dart + generated .g.dart)
  presentation/
    auth/                    # Login, register, splash, welcome, family setup
    home/                    # Dashboard
    items/                   # Item list, detail, add/edit, usage records, scan
    locations/               # Location overview and detail
    alerts/                  # Alert center (expiry, stock, restock, warranty)
    shopping/                # Shopping list
    statistics/              # Usage statistics and charts
    search/                  # Search page
    profile/                 # Profile, family management, categories, notifications
    common/widgets/          # Reusable widgets
```

**Key patterns**:
- `ApiService` (static class in `core/services/api_service.dart`) — centralized HTTP client. All requests go through it; it auto-attaches JWT Bearer tokens, stores/clears tokens via SharedPreferences, and has an auth error callback for session logout.
- API_BASE_URL is resolved at startup from `config/env.local.json` (generated by `setup_env.ps1`) or `--dart-define=API_BASE_URL=...`.
- Drift database (`AppDatabase`) is a singleton. It seeds preset categories and location hierarchy on first run (`seedData()`).
- GoRouter uses `ShellRoute` for the main tab bar (home/items/alerts/profile) and standalone routes for full-screen pages like item detail, add item, scan, etc.

### Platform Targets

Windows desktop, Android, iOS, Web, macOS, Linux. Windows desktop requires Visual Studio 2022 with "Desktop development with C++" workload (including ATL component for flutter_local_notifications).

## Project Coding Rules

### Comments / Annotations

- 新增代码必须添加注释/注解
- 修改代码必须同步更新对应注释/注解

### Logging

- 核心业务代码必须添加日志，覆盖：关键流程 / WARN / ERROR
- UI 层涉及逻辑分支差异时必须打印日志，覆盖：关键流程 / WARN / ERROR

### Change Records

- 每次执行代码编写任务后，必须将改动记录保存到 `lwh/code_changed/` 目录中，以 `.md` 文件格式保存
- 记录内容尽可能包含：
  - 技术开发文档（实现方案、改动点、影响范围）
  - 提测开发文档（测试点、验证方式、注意事项）
- 代码变更时同步更新本地文档，保持文档与代码一致
- 文档文件名要清晰易读

### Prompt Context

- 每次接收提示词时，优先从 `lwh/` 目录中检索基础知识库、代码变更记录等信息，保证上下文的准确性

### Git
- git commit 升成的时候 要使用中文
- commit 格式要有总结 要有1 2 3 的说明

## Testing

- **Backend**: No test framework currently configured. Use `pytest` if adding tests.
- **Frontend**: Tests in `HomeWareClient/test/`. Run with `flutter test`. Currently minimal — one `widget_test.dart`.
