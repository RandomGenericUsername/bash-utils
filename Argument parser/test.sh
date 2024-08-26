#!/bin/bash

# Source the utility
SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/usage.sh" audit clean 340yghi -l /tmp/log_checks /tmp/log_audit -s 2024-09-15 -e 2024-10-01 --json


