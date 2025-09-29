#!/bin/sh
set -e

if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
    echo "NFO: create/check user ${POSTGRES_NON_ROOT_USER} in DB ${POSTGRES_DB}"

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
    "DO \$\$
    BEGIN
       IF NOT EXISTS (
          SELECT FROM pg_catalog.pg_roles WHERE rolname = '${POSTGRES_NON_ROOT_USER}'
       ) THEN
          CREATE ROLE \"${POSTGRES_NON_ROOT_USER}\" LOGIN PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
       END IF;
    END
    \$\$;"

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
        "GRANT CONNECT ON DATABASE \"${POSTGRES_DB}\" TO \"${POSTGRES_NON_ROOT_USER}\";"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
        "GRANT ALL PRIVILEGES ON DATABASE \"${POSTGRES_DB}\" TO \"${POSTGRES_NON_ROOT_USER}\";"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
        "GRANT USAGE, CREATE ON SCHEMA public TO \"${POSTGRES_NON_ROOT_USER}\";"
else
    echo "NFO: No environment variables POSTGRES_NON_ROOT_USER / POSTGRES_NON_ROOT_PASSWORD set!"
fi
