#!/bin/bash
set -euxo pipefail

#function handle_exit() {
#  ${CI_PROJECT_DIR}/scripts/maybe-wait-in-stage.sh WAIT_IN_STAGE_TEST ${CI_PROJECT_DIR}/WAIT_IN_STAGE_TEST;
#  };
#trap handle_exit EXIT

#INTEGRATION_TEST_SUITE=$(mender-qa/integration/extra/release_tool.py --select-test-suite || echo "all")
INTEGRATION_TEST_SUITE=all

#if [ "$INTEGRATION_TEST_SUITE" = "$TEST_SUITE" ] || [ "$INTEGRATION_TEST_SUITE" = "all" ]; then

  # Post job status if in Gitlab
#if [ -z ${CI_PIPELINE_ID+x} ]; then
#  ${CI_PROJECT_DIR+x}/scripts/github_pull_request_status pending "Gitlab ${CI_JOB_NAME+x} started" "${CI_JOB_URL+x}" "${CI_JOB_NAME+x}/${INTEGRATION_REV+x}"
#else
#  log "INFO - running in pipeline - skipping github_pull_request_status"
#fi

echo "INFO - Running backend-tests suite $INTEGRATION_TEST_SUITE"
cd mender-qa/integration/

# From 2.4.x on, the script would download the requirements by default
#if ./run --help | grep -e --no-download; then
#  RUN_ARGS="--no-download";
#fi
#
## for pre 2.2.x releases, ignore test suite selection and just run open tests
#if ./run --help | grep -e --suite; then
#  ./run --suite $TEST_SUITE $RUN_ARGS;
#else
#  PYTEST_ARGS="-k 'not Multitenant'" ./run;
#fi

docker-compose -p backend-tests \
  -f docker-compose.yml \
  -f docker-compose.demo.yml \
  -f docker-compose.storage.minio.yml \
  -f extra/integration-testing/docker-compose.yml \
  -f backend-tests/docker/docker-compose.backend-tests.yml \
  up
  --remove-orphans \
  --scale mender-backend-tests-runner=0 \
  -d

docker-compose -p backend-tests \
  -f docker-compose.yml \
  -f docker-compose.demo.yml \
  -f docker-compose.storage.minio.yml \
  -f extra/integration-testing/docker-compose.yml \
  -f backend-tests/docker/docker-compose.backend-tests.yml \
  run \
  --remove-orphans \
  mender-backend-tests-runner



# Always keep this at the end of the script stage
echo "success" > /JOB_RESULT.txt
#else
#  echo "skipped" > /JOB_RESULT.txt
#fi

")"
