<!--
SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
SPDX-FileCopyrightText: 2024 Leibniz University Hannover

SPDX-License-Identifier: GPL-3.0-or-later
-->

# GNU Health Docker Compose

This Docker Compose spins up the GNU Health Hospital Information System (HIS):

https://docs.gnuhealth.org/his

It contains a PostgreSQL container, an application container running GNU Health through uWSGI and a Nginx container as reverse proxy.

To set it up follow the following instructions:

- [Install Docker](https://docs.docker.com/engine/install/)

- Run docker compose up -d --build

- Install & run GNU Health client using [Ansible](https://docs.gnuhealth.org/ansible/examples/gnuhealth_client.html) or [Vanilla](https://docs.gnuhealth.org/his/techguide/installation/vanilla.html#installation-of-the-gnu-health-client) installation

- Connect to localhost:8080, use 'health' for empty database and 'ghdemo44' for demo database. Username is 'admin' and password 'gnusolidario'.

- Run 'python3 test.py' for non interactive connection test

This is intended for developing and testing purposes - not for productive use!

## Environment Variables

The Docker image can be run with a number of environment variables allowing to configure it. Please see [env template file](/gnuhealth/env.template) for an example. This section explains every variable with a default value (that is set automatically if you don't set another one manually).

**GNUHEALTH_DB_HOST** ("db"): Hostname for PostgreSQL instance.

**GNUHEALTH_DB_PORT** (5432): Port for PostgreSQL instance.

**GNUHEALTH_DB_USERNAME** ("gnuhealth"): Database user name for PostgreSQL instance.

**GNUHEALTH_DB_PW** ("gnusolidario"): Password of database user name.

**GNUHEALTH_DB_NAME** ("health"): Name of database to create, owned by user specified above.

**GNUHEALTH_ADMIN_MAIL** ("example@example.com"): Admin email for Tryton client - does not break the program if it's not a valid one.

**GNUHEALTH_ADMIN_PW** ("gnusolidario"): Admin password in Tryton client (or Proteus if scripted access).

**GNUHEALTH_DEMO_DB** (true): Boolean to specify if demo database should be installed as well.

## Adding HTTPS

If you want to add HTTPS, follow this steps:

- Add your certificate and key

- Uncomment Option B in web-site/reverse_proxy.conf and insert your paths (or leave A & B)

- Uncomment the line "- 8443:443" on the bottom of docker-compose.yml
