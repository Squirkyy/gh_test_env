FROM python:3.11.8-bookworm

# Install dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client wget expect graphviz \
    libreoffice-writer-nogui libreoffice-calc-nogui \
    vim && \
    pip3 install uwsgi

# Create a dedicated non-root user "gnuhealth"
RUN adduser --disabled-password --gecos "" gnuhealth

# Download the demo database dump
RUN cd /tmp/ && wget https://www.gnuhealth.org/downloads/postgres_dumps/gnuhealth-44-demo.sql.gz && \
    gunzip gnuhealth-44-demo.sql.gz

# Copy local Tryton directory (includes gnuhealth-setup and start_gnuhealth.sh)
COPY src/tryton /opt/gnuhealth/tryton

# Ensure required directories exist and copy configuration file
RUN mkdir -p /opt/gnuhealth/etc /opt/gnuhealth/var/log /opt/gnuhealth/var/lib && \
    mkdir -p /opt/gnuhealth/tryton/modules && \
    cp /opt/gnuhealth/tryton/config/trytond.conf /opt/gnuhealth/etc/ && \
    cp /opt/gnuhealth/tryton/config/gnuhealth_log.conf /opt/gnuhealth/etc/ && \
    chown -R gnuhealth:gnuhealth /opt/gnuhealth/etc

RUN mkdir -p /opt/gnuhealth/tryton/gnuhealth /opt/gnuhealth/tryton/modules /opt/gnuhealth/bin /opt/gnuhealth/doc
# Create minimal .gnuhealthrc with necessary env variables
RUN echo 'export GNUHEALTH_INST_DIR=/opt/gnuhealth/tryton' > /home/gnuhealth/.gnuhealthrc && \
    echo 'export MODULES_DIR=/opt/gnuhealth/tryton/modules' >> /home/gnuhealth/.gnuhealthrc && \
    chown gnuhealth:gnuhealth /home/gnuhealth/.gnuhealthrc

# Create expected Tryton server structure by symlinking the pip-installed trytond
RUN mkdir -p /opt/gnuhealth/tryton/server/trytond-5.0.20/bin && \
    ln -si /usr/local/bin/trytond /opt/gnuhealth/tryton/server/trytond-5.0.20/bin/trytond
RUN pip3 install trytond
RUN mkdir -p /opt/gnuhealth/tryton/server/trytond-5.0.20/bin && \
    ln -si "$(which trytond)" /opt/gnuhealth/tryton/server/trytond-5.0.20/bin/trytond


# Copy additional configuration and supporting files
COPY ./trytond.ini /opt/gnuhealth/etc/trytond.ini
COPY ./init_and_run.sh /scripts/init_and_run.sh
COPY ./init /scripts/init
COPY ./banner.txt /tmp/banner.txt

# Ensure scripts are executable
RUN chmod +x /opt/gnuhealth/tryton/gnuhealth-setup \
    /opt/gnuhealth/tryton/start_gnuhealth.sh \
    /scripts/init_and_run.sh

RUN chown -R gnuhealth:gnuhealth /opt/gnuhealth /home/gnuhealth
RUN chmod +x /scripts/init
USER gnuhealth
ENV HOME=/home/gnuhealth

ENTRYPOINT ["/scripts/init_and_run.sh"]

# CMD ["tail", "-f", "/dev/null"]
