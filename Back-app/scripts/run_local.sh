#!/usr/bin/env bash
set -euo pipefail

if [ ! -d ".venv" ]; then
  python -m venv .venv
fi

.venv/bin/pip install -r requirements.txt
.venv/bin/python manage.py migrate --settings=core.settings.local
.venv/bin/python manage.py runserver --settings=core.settings.local 0.0.0.0:8000
