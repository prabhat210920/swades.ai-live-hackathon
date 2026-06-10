#!/usr/bin/env bash
# build.sh — Render build script
# Render runs this automatically before starting your web service.

set -o errexit   # exit on any error

pip install --upgrade pip
pip install -r requirements.txt

# Collect static files (WhiteNoise will serve them)
python manage.py collectstatic --no-input

# Run database migrations
python manage.py migrate

# Seed initial data (safe to run multiple times — uses get_or_create)
python manage.py seed
