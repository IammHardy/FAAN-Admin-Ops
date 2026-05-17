#!/bin/bash

set -e

mkdir -p backups

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="backups/faan_backup_${TIMESTAMP}.sql"

echo "Starting database backup..."

PG_DUMP="/usr/lib/postgresql/18/bin/pg_dump"

$PG_DUMP "$DATABASE_PUBLIC_URL" > "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"
du -h "$BACKUP_FILE"