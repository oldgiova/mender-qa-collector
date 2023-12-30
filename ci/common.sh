#!/bin/bash

RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
BLU='\033[1;34m'
WHT='\033[1;37m'
MGT='\033[1;95m'
CYA='\033[1;96m'
END='\033[0m'
BLOCK='\033[1;37m'

PATH=/usr/local/bin:$PATH
export PATH

# wait for Enter key to be pressed
function pause(){
  read -rp "[Enter] Continue..."
}

# show info text and command, wait for enter, then execute and print a newline
function info_pause_exec() {
  step "$1"
  read -rp $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [Enter]"
  exe "$2"
  echo ""
}

# show info text and command, wait for enter, then execute and print a newline
# skip wait for enter if in pipeline
function info_pause_exec_pipeline() {
  step "$1"
  if [ -z ${CI_PIPELINE_ID+x} ]; then
    read -rp $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [Enter]"
  else
    echo $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'
  fi
  exe "$2"
  echo ""
}

# show info text and command, then execute and print a newline
function info_exec() {
  step "$1"
  echo $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [Enter]"
  exe "$2"
  echo ""
}

# show info text and command, wait for chosen option
function info_pause_exec_options() {
  step "$1"

  read -p $'\033[1;37m#\033[0m'" Command: "$'\033[1;96m'"$2"$'\033[0m'" [y/n] > " -r -n 1 choice
  case "$choice" in 
    y|Y )
      echo ""
      exe "$2"
      echo ""
      return 0
      ;;
    n|N )
      echo ""
      echo "Not executed."
      return 0
      ;;
    * )
      echo ""
      echo "Invalid Choice. Type y or n."
      info_pause_exec_options "$1" "$2" # restart process on invalid choice
      ;;
  esac
  
}

# show command and execute it
exe() {
  echo "\$ $1"
  eval "$1"
}

# highlight a new section
section() {
  echo ""
  log "***** Section: ${MGT}$1${END} *****"; 
  echo ""
}

# highlight a new section but ask for confirmation to run it
proceed_or_not() {
  read -p $'\033[1;37m#\033[0m\033[1;33m'" Proceed with $1?"$'\033[0m'" [y/n] > " -r -n 1 choice
  case "$choice" in 
    y|Y )
      echo -e "\n"
      return 0
      ;;
    n|N )
      echo -e "\n"
      return 1
      ;;
    * )
      echo ""
      echo "Invalid Choice. Type y or n."
      proceed_or_not "$1" "$2" # restart process on invalid choice
      ;;
  esac
}

# highlight the next step
step() { log "Step: ${BLU}$1${END}"; }

# output a "log" line with bold leading >>>
log() { >&2 printf "${BLOCK}#${END} $1\n"; }

cleanup_old_build_directory_v1() {
  rm -rf ./.build || log "INFO - .build dir not found. Ignoring"
}

create_new_build_directory_v1() {
  timestamp=$(date +%Y%m%d-%H%M%S)
  echo "BUILDDIR=.build/${timestamp}" > .build_info
  mkdir -p .build/${timestamp}
}

assign_cizero_build_id_v1() {
  BUILD_ID=$(echo $RANDOM | md5sum | head -c 15; echo;)
  echo "CIZERO_BUILD_ID=$BUILD_ID" >> .build_info
}

docker_local_toolbox_build_v1() {
  #docker context create builder || log "INFO - docker context already exists"

  #docker buildx create \
  #  --name builder \
  #  --driver-opt network=host \
  #  --buildkitd-flags '--debug --allow-insecure-entitlement network.host' \
  #    || log "INFO - builder already exists"

  #docker buildx use builder

  #docker buildx build \
  docker build \
    --tag cizero:local-toolbox \
    --file ci/Dockerfile \
    --build-arg USER=$(whoami) \
    --build-arg USER_UID=$(id -u ${USER}) \
    --build-arg USER_GID=$(id -g ${USER}) \
    --build-arg DOCKER_HUB_USER=${DOCKER_HUB_USER} \
    --secret id=docker_hub_password,env=DOCKER_HUB_PASSWORD \
    --build-arg REGISTRY_MENDER_IO_USER=${REGISTRY_MENDER_IO_USER} \
    --secret id=registry_mender_io_password,env=REGISTRY_MENDER_IO_PASSWORD \
    --build-arg GITLAB_USER=${GITLAB_USER} \
    --secret id=gitlab_pat,env=GITLAB_PAT \
    ci/
  #docker buildx stop
  #docker buildx rm
}

docker_local_toolbox_run_v1() {
  docker run \
    --detach \
    --privileged \
    --name cizero-${CIZERO_BUILD_ID} \
    --rm \
    cizero:local-toolbox
}

docker_local_toolbox_cleanup_v1() {
  docker stop \
      cizero-${CIZERO_BUILD_ID} \
    && docker rm \
      cizero-${CIZERO_BUILD_ID} || log "INFO - container already removed"
}

docker_dind_run_v1() {
  docker run \
    --detach \
    --privileged \
    --name cizero-${CIZERO_BUILD_ID} \
    --rm \
    docker:24.0.6-dind-rootless
}

docker_exec_v1() {
  docker exec \
    --interactive \
    --tty \
    cizero-${CIZERO_BUILD_ID} \
    $@
}

docker_exec_ci_aware_v1() {
  if [ -z ${CI_PIPELINE_ID+x} ]; then
    docker exec \
      --interactive \
      --tty \
      cizero-${CIZERO_BUILD_ID} \
      $@
  else
    log "INFO - running in pipeline - skipping command $@"
  fi

}
