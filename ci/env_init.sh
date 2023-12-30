#!/bin/bash
set -euxo pipefail

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }
source "$CURR_DIR/common.sh"
source .build_info

#
# .build/tmpdir
#
cleanup_old_build_directory_v1
create_new_build_directory_v1
assign_cizero_build_id_v1
