#!/bin/sh
set -e

# Aplica as migrações (idempotente) e troca o processo pelo Node,
node dist/db/migrate.js
exec node dist/server.js