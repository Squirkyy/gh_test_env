#!/bin/bash

# SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
# SPDX-FileCopyrightText: 2024 Leibniz University Hannover
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Load banner
grep -v '^#' /tmp/banner.txt 
echo

# -------------------------------------
# Set environment variables
# -------------------------------------
echo "Checking which env vars are present"

DB_HOSTNAME=${GNUHEALTH_DB_HOST:-db}
DB_PORT=${GNUHEALTH_DB_PORT:-5432}
DB_USERNAME=${GNUHEALTH_DB_USERNAME:-gnuhealth}
DB_PW=${GNUHEALTH_DB_PW:-gnusolidario}
DB_NAME=${GNUHEALTH_DB_NAME:-health}
ADMIN_MAIL=${GNUHEALTH_ADMIN_MAIL:-example@example.com}
ADMIN_PW=${GNUHEALTH_ADMIN_PW:-gnusolidario}
DEMO_DB=${GNUHEALTH_DEMO_DB:-false}

echo "Using DB Hostname: $DB_HOSTNAME"
echo "Using DB Port: $DB_PORT"
echo "Using DB Username: $DB_USERNAME"
echo "Using DB Name: $DB_NAME"
echo "Using Admin Mail: $ADMIN_MAIL"

# -------------------------------------
# Update trytond.conf with DB settings
# -------------------------------------
sed -i "s#uri = .*#uri = postgresql://${DB_USERNAME}:${DB_PW}@${DB_HOSTNAME}:${DB_PORT}/#" /opt/gnuhealth/etc/trytond.conf

# -------------------------------------
# Run GNU Health Setup
# -------------------------------------
echo "Running GNU Health setup..."
/opt/gnuhealth/gnuhealth-setup install

# -------------------------------------
# Set up the demo database (if applicable)
# -------------------------------------
if [[ "$DEMO_DB" == "true" ]]; then
  echo "Creating local demo database if not exists..."
  export PGPASSWORD=$DB_PW
  if ! psql -h $DB_HOSTNAME -U $DB_USERNAME -lqt | cut -d \| -f 1 | grep -w ghdemo44; then
    createdb -h $DB_HOSTNAME -U $DB_USERNAME ghdemo44
    psql -h $DB_HOSTNAME -U $DB_USERNAME ghdemo44 < /tmp/gnuhealth-44-demo.sql
  fi
fi

# -------------------------------------
# Initialize database if not done already
# -------------------------------------
echo "Initializing fresh database if not done already..."
if ! psql -h $DB_HOSTNAME -U $DB_USERNAME -d $DB_NAME -c "\dt" | grep res_user; then
  /scripts/init $ADMIN_MAIL $ADMIN_PW $DB_NAME
fi

# -------------------------------------
# Start GNU Health
# -------------------------------------
echo "Starting GNU Health..."
exec /opt/gnuhealth/start_gnuhealth.sh
