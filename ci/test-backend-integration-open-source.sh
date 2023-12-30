#!/bin/bash
set -euxo pipefail

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }
source "$CURR_DIR/common.sh"

source .build_info

section "workspace preparation"

#docker_local_toolbox_build_v1
#docker_local_toolbox_run_v1
docker_dind_run_v1

sleep 20
docker_exec_v1 "cat /etc/os-release"

#test:backend-integration:open_source:
#  tags:
#    - mender-qa-worker-backend-integration-tests
#  rules:
#  - if: '$RUN_BACKEND_INTEGRATION_TESTS == "true"'
#    when: always
#  stage: test
#  image: docker/compose:alpine-1.27.4
#  variables:
#    TEST_SUITE: "open"
#  services:
#    - docker:dind
#  needs:
#    - init:workspace
#    - build:servers
#    - build:mender-artifact
#  before_script:
#    # Default value, will later be overwritten if successful
#    - echo "failure" > /JOB_RESULT.txt
#
#    # Increase inotify limit to make sure the tests are not limited while
#    # running with high parallelism on a single VM
#    - sysctl -w fs.inotify.max_user_instances=1024
#
#    # Set minimaly required by Opensearch 'max virtual memory areas'
#    # https://opensearch.org/docs/2.4/install-and-configure/install-opensearch/index/#important-settings
#    - sysctl -w vm.max_map_count=262144
#
#    - docker version
#    - apk --update add bash git py-pip gcc make python2-dev
#      libc-dev libffi-dev openssl-dev python3 curl jq sysstat xz
#    - wget https://raw.githubusercontent.com/mendersoftware/integration/master/extra/requirements.txt
#    - pip3 install -r requirements.txt
#    # Restore workspace from init stage
#    - export WORKSPACE=$(realpath ${CI_PROJECT_DIR}/..)
#    - mv workspace.tar.xz build_revisions.env stage-artifacts /tmp
#    - rm -rf ${WORKSPACE}
#    - mkdir -p ${WORKSPACE}
#    - cd ${WORKSPACE}
#    - xz -d /tmp/workspace.tar.xz
#    - tar -xf /tmp/workspace.tar
#    - mv /tmp/build_revisions.env /tmp/stage-artifacts .
#
#
#    # Load all docker images except client
#    - for image in $(integration/extra/release_tool.py -l docker); do
#    -   if ! echo $image | egrep -q 'mender-client|mender-qemu|mender-monitor|mender-gateway'; then
#    -     docker load -i stage-artifacts/${image}.tar
#    -   fi
#    - done
#    # Login for private repos
#    - docker login -u menderbuildsystem -p ${DOCKER_HUB_PASSWORD}
#    - docker login -u ntadm_menderci -p ${REGISTRY_MENDER_IO_PASSWORD} registry.mender.io
#    # Set testing versions to PR
#    - for repo in `integration/extra/release_tool.py -l docker`; do
#        integration/extra/release_tool.py --set-version-of $repo --version pr;
#      done
#    # mender-artifact
#    - mkdir -p integration/backend-tests/downloaded-tools
#    - mv stage-artifacts/mender-artifact-linux integration/backend-tests/downloaded-tools/mender-artifact
#    # copy for pre 2.4.x releases
#    - cp integration/backend-tests/downloaded-tools/mender-artifact integration/backend-tests/mender-artifact
#    # sysstat monitoring suite for Alpine Linux
#    # collect cpu, load avg, memory and io usage every 2 secs forever
#    # use 'sar' from sysstat to render the result file manually
#    - ln -s /var/log/sa/ /var/log/sysstat
#    - sar -P ALL 2 -o /var/log/sysstat/sysstat.log -uqrbS >/dev/null 2>&1 &
#
#
#  script:
#    # Traps only work if executed in a sub shell.
#    - "("
#
#    - function handle_exit() {
#      ${CI_PROJECT_DIR}/scripts/maybe-wait-in-stage.sh WAIT_IN_STAGE_TEST ${CI_PROJECT_DIR}/WAIT_IN_STAGE_TEST;
#      };
#      trap handle_exit EXIT
#
#    - INTEGRATION_TEST_SUITE=$(integration/extra/release_tool.py --select-test-suite || echo "all")
#
#    - if [ "$INTEGRATION_TEST_SUITE" = "$TEST_SUITE" ] || [ "$INTEGRATION_TEST_SUITE" = "all" ]; then
#        # Post job status
#    -   ${CI_PROJECT_DIR}/scripts/github_pull_request_status pending "Gitlab ${CI_JOB_NAME} started" "${CI_JOB_URL}" "${CI_JOB_NAME}/${INTEGRATION_REV}"
#
#    -   echo Running backend-tests suite $INTEGRATION_TEST_SUITE
#    -   cd integration/backend-tests/
#
#        # From 2.4.x on, the script would download the requirements by default
#    -   if ./run --help | grep -e --no-download; then
#    -     RUN_ARGS="--no-download";
#    -   fi
#
#        # for pre 2.2.x releases, ignore test suite selection and just run open tests
#    -   if ./run --help | grep -e --suite; then
#    -     ./run --suite $TEST_SUITE $RUN_ARGS;
#    -   else
#    -     PYTEST_ARGS="-k 'not Multitenant'" ./run;
#    -   fi
#
#        # Always keep this at the end of the script stage
#    -   echo "success" > /JOB_RESULT.txt
#    - else
#    -   echo "skipped" > /JOB_RESULT.txt
#    - fi
#
#    - ")"
#  after_script:
#    - export WORKSPACE=$(realpath ${CI_PROJECT_DIR}/..)
#    - if [ "$(cat /JOB_RESULT.txt)" != "skipped" ]; then
#    -   if [ "$(cat /JOB_RESULT.txt)" != "success" ]; then ${CI_PROJECT_DIR}/scripts/github_pull_request_status $(cat /JOB_RESULT.txt) "Gitlab ${CI_JOB_NAME} finished" "${CI_JOB_URL}" "${CI_JOB_NAME}/${INTEGRATION_REV}"; fi
#
#    -   find ${CI_PROJECT_DIR}/../integration/backend-tests -mindepth 1 -maxdepth 1 -name 'acceptance.*' -exec cp "{}" . \;
#    -   ls ${CI_PROJECT_DIR}/../integration/backend-tests/results_*xml | xargs -n 1 -i cp {} .
#    -   ls ${CI_PROJECT_DIR}/../integration/backend-tests/report_*html | xargs -n 1 -i cp {} .
#
#    -   if [ "$NIGHTLY_BUILD" = "true" ]; then
#    -     build_name=nightly-$(date +%Y-%m-%d)
#    -   else
#    -     build_name=pullreq-$(date +%Y-%m-%d)-${CI_PIPELINE_ID}
#    -   fi
#    -   if [ "$TEST_SUITE" = "open" ]; then
#    -     mantra_id=$MANTRA_ID_backend_integration_open_source
#    -     results_file=results_backend_integration_open.xml
#    -   elif [ "$TEST_SUITE" = "enterprise" ]; then
#    -     mantra_id=$MANTRA_ID_backend_integration_enterprise
#    -     results_file=results_backend_integration_enterprise.xml
#    -   fi
#    -   ${CI_PROJECT_DIR}/scripts/mantra_post_test_results
#          $mantra_id
#          $build_name
#          $results_file || true
#
#    -   cp /var/log/sysstat/sysstat.log .
#    -   sadf sysstat.log -g -- -qurbS > sysstat.svg
#
#        # Post job status
#    -   ${CI_PROJECT_DIR}/scripts/github_pull_request_status $(cat /JOB_RESULT.txt) "Gitlab ${CI_JOB_NAME} finished" "${CI_JOB_URL}" "${CI_JOB_NAME}/${INTEGRATION_REV}"
#    - fi
#
#  artifacts:
#    expire_in: 2w
#    when: always
#    paths:
#      - acceptance.*
#      - results_backend_integration_*.xml
#      - report_backend_integration_*.html
#      - sysstat.log
#      - sysstat.svg
#    reports:
#      junit: results_backend_integration_*.xml
#
