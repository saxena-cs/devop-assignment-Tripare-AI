#!/usr/bin/env bash
set -euo pipefail

BACKUP_FILE="${1:-}"

if [ -z "${BACKUP_FILE}" ]; then
  BACKUP_FILE="$(ls -t backups/hotel_db_*.sql | head -n 1)"
fi

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

RESTORE_DB="hotel_db_restore"

echo "Restoring backup from: ${BACKUP_FILE}"
echo "Target restore database: ${RESTORE_DB}"

docker compose exec -T postgres psql -U app_user -d postgres -c "DROP DATABASE IF EXISTS ${RESTORE_DB};"
docker compose exec -T postgres psql -U app_user -d postgres -c "CREATE DATABASE ${RESTORE_DB};"

cat "${BACKUP_FILE}" | docker compose exec -T postgres psql -U app_user -d "${RESTORE_DB}"

echo "Restore completed successfully."

echo "Verification:"
docker compose exec -T postgres psql -U app_user -d "${RESTORE_DB}" -c "
SELECT COUNT(*) AS restored_hotel_bookings FROM hotel_bookings;
"

docker compose exec -T postgres psql -U app_user -d "${RESTORE_DB}" -c "
SELECT COUNT(*) AS restored_booking_events FROM booking_events;
"
