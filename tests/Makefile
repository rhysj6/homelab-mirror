.PHONY: help test-kubernetes test-kubernetes-no-teardown test-kubernetes-dev report-kubernetes test-all

K8S_TEST_DIR := ./kubernetes
GOTEST := go test -v -timeout 0 -count 1

help:
	@echo "  test-kubernetes              Run kubernetes tests (default: setup and teardown enabled)"
	@echo "  test-kubernetes-no-teardown  Run kubernetes tests without cluster teardown"
	@echo "  test-kubernetes-dev          Run kubernetes tests without setup or teardown"
	@echo "  report-kubernetes            Generate kubernetes test report"
	@echo "  test-all                     Run all test suites"

test-kubernetes:
	@echo "Running kubernetes tests..."
	cd $(K8S_TEST_DIR) && $(GOTEST) . | tee test_output.log

test-kubernetes-no-teardown:
	@echo "Running kubernetes tests (skipping teardown)..."
	cd $(K8S_TEST_DIR) && KUBE_TEST_SKIP_TEARDOWN=true $(GOTEST) . | tee test_output.log

test-kubernetes-dev:
	@echo "Running kubernetes tests (skipping setup and teardown)..."
	cd $(K8S_TEST_DIR) && KUBE_TEST_SKIP_SETUP=true KUBE_TEST_SKIP_TEARDOWN=true $(GOTEST) . | tee test_output.log

report-kubernetes:
	@echo "Generating test report..."
	cd $(K8S_TEST_DIR) && terratest_log_parser -testlog test_output.log -outputdir test_output

test-all: test-kubernetes
