#!/bin/bash

# SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
# SPDX-FileCopyrightText: 2024 Leibniz University Hannover
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Load banner
grep -v '^#' /tmp/banner.txt 
echo
export GNUHEALTH_DIR=/opt/gnuhealth
export GNUHEALTH_INST_DIR=/opt/gnuhealth/tryton
export MODULES_DIR=/opt/gnuhealth/tryton/modules
export TRYTOND=trytond-5.0.20
export BASEDIR=/opt/gnuhealth
export CONFIG_DIR=/opt/gnuhealth/etc
export UTIL_DIR=/opt/gnuhealth/bin
export DOC_DIR=/opt/gnuhealth/doc
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
source ${HOME}/.gnuhealthrc
echo "DEBUG: GNUHEALTH_INST_DIR is set to: ${GNUHEALTH_INST_DIR}"
sed -i "s#uri = .*#uri = postgresql://${DB_USERNAME}:${DB_PW}@${DB_HOSTNAME}:${DB_PORT}/#" /opt/gnuhealth/etc/trytond.conf

# -------------------------------------
# Set up the demo database (if applicable)
# -------------------------------------
if [[ "$DEMO_DB" == "false" ]]; then
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


export PGPASSWORD=$DB_PW
/scripts/init $ADMIN_MAIL $ADMIN_PW $DB_NAME

echo "DEBUG: Changing directory to GNUHEALTH_INST_DIR: ${GNUHEALTH_INST_DIR}"
cd "${GNUHEALTH_INST_DIR}" || { echo "ERROR: Cannot cd to ${GNUHEALTH_INST_DIR}"; exit 1; }

# Ensure the installer finds the GNU Health shell profile file.
if [ ! -f "gnuhealthrc" ]; then
    echo "DEBUG: File 'gnuhealthrc' not found. Copying from ${HOME}/.gnuhealthrc..."
    cp --preserve=mode "${HOME}/.gnuhealthrc" "gnuhealthrc" || { echo "ERROR: Failed to copy .gnuhealthrc"; exit 1; }
    chown gnuhealth:gnuhealth gnuhealthrc
fi

echo "DEBUG: Contents of GNUHEALTH_INST_DIR:"
ls -l


if [ -w /home/gnuhealth/.gnuhealthrc ]; then
  cp /home/gnuhealth/.gnuhealthrc /home/gnuhealth/.gnuhealthrc.bak
else
  echo "Permission denied: Unable to write to /home/gnuhealth/.gnuhealthrc"
  exit 1
fi

# -------------------------------------
# Run GNU Health Setup
# -------------------------------------
echo "Running GNU Health setup..."
/opt/gnuhealth/tryton/gnuhealth-setup install

echo "DEBUG: Checking database connectivity..."

export PGPASSWORD=$DB_PW

# Try connecting to the database
if ! psql -h "$DB_HOSTNAME" -U "$DB_USERNAME" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
  echo "ERROR: Cannot connect to the database at $DB_HOSTNAME:$DB_PORT as $DB_USERNAME"
  echo "       Check if the database container is running and accepting connections."
  exit 1
else
  echo "SUCCESS: Connected to the database!"
fi


# -------------------------------------
# Start GNU Health
# -------------------------------------
echo "Starting GNU Health..."
exec /opt/gnuhealth/tryton/start_gnuhealth.sh --config /opt/gnuhealth/etc/trytond.conf
