# SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
# SPDX-License-Identifier: 2024 Leibniz University Hannover
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM python:3.11.8-bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client wget expect graphviz \
    libreoffice-writer-nogui libreoffice-calc-nogui && \
    pip3 install uwsgi

# Download the demo database dump
RUN cd /tmp/ && wget https://www.gnuhealth.org/downloads/postgres_dumps/gnuhealth-44-demo.sql.gz && \
    gunzip gnuhealth-44-demo.sql.gz

# Copy local Tryton directory (which includes gnuhealth-setup and start_gnuhealth.sh)
COPY src/tryton /opt/gnuhealth/tryton

# Ensure required directories exist and copy configuration files
RUN mkdir -p /opt/gnuhealth/etc /opt/gnuhealth/var/log /opt/gnuhealth/var/lib && \
    cp /opt/gnuhealth/tryton/etc/trytond.conf /opt/gnuhealth/etc/ && \
    cp /opt/gnuhealth/tryton/etc/gnuhealth_log.conf /opt/gnuhealth/etc/

# Copy configuration and supporting files
COPY ./trytond.ini /opt/gnuhealth/etc/trytond.ini
COPY ./banner.txt /tmp/banner.txt

# Ensure scripts are executable (including the ones inside /opt/gnuhealth/tryton)
RUN chmod +x /opt/gnuhealth/tryton/gnuhealth-setup \
    /opt/gnuhealth/tryton/start_gnuhealth.sh \
    /scripts/init_and_run.sh

# Copy the init_and_run.sh script, which will now use gnuhealth-setup
COPY ./init_and_run.sh /scripts/init_and_run.sh

# Entry point for container
ENTRYPOINT ["/scripts/init_and_run.sh"]