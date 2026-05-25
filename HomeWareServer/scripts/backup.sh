#!/bin/bash
# Database backup script for HomeStock
# Creates gzipped SQL backups and retains last 30 days

set -e

# Configuration
BACKUP_DIR="/backups"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASS="${POSTGRES_PASSWORD:-password}"
DB_NAME="${POSTGRES_DB:-homestock}"
DB_HOST="${POSTGRES_HOST:-db}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="homestock_${DATE}.sql.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup..."

# Create backup
PGPASSWORD="$DB_PASS" pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_PATH"

# Verify backup
if [ -f "$BACKUP_PATH" ]; then
    echo "Backup created successfully: $BACKUP_FILENAME"
    echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"
    
    # Clean up old backups (keep last 30 days)
    echo "Cleaning up old backups..."
    find "$BACKUP_DIR" -name "homestock_*.sql.gz" -mtime +30 -delete
    
    echo "Backup completed successfully!"
else
    echo "ERROR: Backup failed!"
    exit 1
fi
