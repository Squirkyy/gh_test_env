# SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
# SPDX-FileCopyrightText: 2024 Leibniz University Hannover
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM python:3.11.8-bookworm

RUN apt-get update && apt-get install -y postgresql-client wget && \
  cd /tmp/ && wget https://www.gnuhealth.org/downloads/postgres_dumps/gnuhealth-44-demo.sql.gz && \
  gunzip gnuhealth-44-demo.sql.gz

RUN apt-get install -y expect graphviz libreoffice-writer-nogui libreoffice-calc-nogui && \
  pip3 install uwsgi

COPY src/tryton /opt/gnuhealth/tryton


RUN mkdir -p /opt/gnuhealth/etc /opt/gnuhealth/var/log /opt/gnuhealth/var/lib && \
  cp /opt/gnuhealth/tryton/etc/trytond.conf /opt/gnuhealth/etc/ && \
  cp /opt/gnuhealth/tryton/etc/gnuhealth_log.conf /opt/gnuhealth/etc/

COPY ./trytond.ini /opt/gnuhealth/etc/trytond.ini
COPY ./init_and_run.sh /scripts/init_and_run.sh
COPY ./init /scripts/init
COPY ./banner.txt /tmp/banner.txt

RUN chmod +x /scripts/init_and_run.sh
RUN chmod +x /scripts/init

ENTRYPOINT ["/scripts/init_and_run.sh"]
