#!/bin/bash

set -e

exec python3 -m http.server $STATIC_PORT --directory /var/www/static
