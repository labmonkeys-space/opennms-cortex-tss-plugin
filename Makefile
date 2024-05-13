###
# Makefile to build the Cortex plugin
###
.DEFAULT_GOAL := compile

SHELL                 := /bin/bash -o nounset -o pipefail -o errexit
ARTIFACTS_DIR         := target/artifacts

.PHONY: deps
deps:
	@echo "Check if mvn is in the search path"
	command -v mvn

.PHONY: deps-docker
deps-docker:
	@echo "Check if Docker is available in the search path"
	command -v docker
	@echo "Check if Docker daemon is running, for integration tests"
	docker ps -q

.PHONY: validate
validate: deps
	mvn validate

.PHONY: compile
compile: validate
	mvn -DskipITs=true -DskipTests=true clean install

.PHONY: tests
tests: compile deps-docker
	mvn -DskipITs=false -DskipTests=false clean install test integration-test

.PHONY: collect-testresults
collect-testresults:
	mkdir -p $(ARTIFACTS_DIR)/failsafe-reports $(ARTIFACTS_DIR)/surefire-reports
	find . -type f -regex ".*/target/failsafe-reports/.*xml" -exec cp {} $(ARTIFACTS_DIR)/failsafe-reports \;
	find . -type f -regex ".*/target/surefire-reports/.*xml" -exec cp {} $(ARTIFACTS_DIR)/surefire-reports \;
