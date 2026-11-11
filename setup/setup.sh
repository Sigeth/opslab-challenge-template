#!/bin/sh
# Runs once as root when the instance is provisioned: build the broken state
# the student has to fix.
set -eu
useradd --system --no-create-home app 2>/dev/null || true
mkdir -p /opt/app
echo "s3cr3t-token" > /opt/app/token
chown root:root /opt/app/token
chmod 0666 /opt/app/token
