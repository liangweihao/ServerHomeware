#!/bin/bash

python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear

celery -A home_inventory worker -l info &
celery -A home_inventory beat -l info &

gunicorn home_inventory.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120
