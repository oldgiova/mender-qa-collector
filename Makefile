SHELL := /bin/bash

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: backend-run-master
backend-run-master: ## Run Mender QA for current master
	@echo "Run Backend tests on Master"
	./ci/run.sh backend_integration_tests_opensource
