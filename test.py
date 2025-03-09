# SPDX-FileCopyrightText: 2024 Gerald Wiese <wiese@gnuhealth.org>
# SPDX-FileCopyrightText: 2024 Leibniz University Hannover
#
# SPDX-License-Identifier: GPL-3.0-or-later

from proteus import config
print('Connecting to the fresh database')
conf = config.set_xmlrpc("http://admin:gnusolidario@localhost:8080/health/")
print('Success')
print('Connecting to the local demo database')
conf = config.set_xmlrpc("http://admin:gnusolidario@localhost:8080/ghdemo44/")
print('Success')
