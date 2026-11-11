#!/bin/sh
# Runs once when the instance is provisioned, as the machine's user (UID 1000
# on pod machines): build the broken state the student has to fix.
set -eu
mkdir -p "$HOME/app"
echo "s3cr3t-token" > "$HOME/app/token"
chmod 0666 "$HOME/app/token"
chmod 0777 "$HOME/app"
