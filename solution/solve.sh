#!/bin/sh
# Reference solution: `opslab challenge test` runs it to check that the tasks
# can be solved (all checks fail before, pass after). Published separately,
# for teachers only.
set -eu
chown app /opt/app/token
chmod 0600 /opt/app/token
