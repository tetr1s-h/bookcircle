#!/usr/bin/env bash
# Запуск на Render: миграции, демо-данные на пустой базе, сервер.
set -e
mkdir -p "$(dirname "${BOOKCIRCLE_DB:-bookcircle.db}")"
python manage.py migrate
python - <<'PY'
from app import db
from app.seed import seed
conn = db.connect()
if not conn.execute("SELECT COUNT(*) AS n FROM users").fetchone()["n"]:
    seed(conn)
    print("Демо-данные добавлены")
PY
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}" --proxy-headers --forwarded-allow-ips="*"
