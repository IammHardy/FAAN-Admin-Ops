#!/bin/bash

set -e

mkdir -p backups

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="backups/faan_backup_${TIMESTAMP}.sql"

DATABASE_URL_TO_USE="${DATABASE_PUBLIC_URL:-$DATABASE_URL}"

if [ -z "$DATABASE_URL_TO_USE" ]; then
  echo "Error: DATABASE_PUBLIC_URL or DATABASE_URL is not set."
  exit 1
fi

echo "Starting database backup..."
PG_DUMP="/usr/lib/postgresql/18/bin/pg_dump"


$PG_DUMP "$DATABASE_URL_TO_USE" > "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"
du -h "$BACKUP_FILE"
