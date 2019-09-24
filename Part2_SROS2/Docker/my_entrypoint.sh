#!/bin/bash
set -e

# start ssh service
service ssh start

exec "$@"
