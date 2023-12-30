#!/bin/bash
set -euo pipefail

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }
source "$CURR_DIR/common.sh"

#
# build init
# 
$CURR_DIR/env_init.sh

section "Running Pipeline"
log "INFO - Pipeline start\n"
printf "${CYA}********************${END}\n# Start\n${CYA}********************${END}\n"

case $1 in
  "backend_integration_tests_opensource")
    info_pause_exec_pipeline "Running backend integration tests" "$CURR_DIR/test-backend-integration-open-source.sh"
    ;;
  "*")
    log "ERROR - step missing - usage: mender-os-setup.sh <step>"
    exit 1
    ;;
esac
