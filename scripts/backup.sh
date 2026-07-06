#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/hotel_db_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "Creating backup: ${BACKUP_FILE}"

docker compose exec -T postgres pg_dump \
  -U app_user \
  -d hotel_db \
  --no-owner \
  --no-privileges \
  > "${BACKUP_FILE}"

echo "Backup completed successfully."
echo "Backup file: ${BACKUP_FILE}"
