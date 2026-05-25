package helpers

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
)

func IsSetupClusterEnabled() bool {
	return os.Getenv("KUBE_TEST_SKIP_SETUP") != "true"
}

func IsTeardownClusterEnabled() bool {
	return os.Getenv("KUBE_TEST_SKIP_TEARDOWN") != "true"
}

func SetupCluster(t *testing.T) {
	if !IsSetupClusterEnabled() {
		t.Log("SetupCluster is disabled, skipping cluster setup")
		return
	}
	ctx := t.Context()

	tgStackOpts := &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"apply"},
	}

	// Clean and generate the terragrunt stack before running the test
	terragrunt.StackCleanContext(t, ctx, tgStackOpts)
	terragrunt.StackGenerateContext(t, ctx, tgStackOpts)

	terragrunt.StackRunContext(t, ctx, tgStackOpts)
}

func TeardownCluster(t *testing.T) {
	if !IsTeardownClusterEnabled() {
		t.Log("TeardownCluster is disabled, skipping cluster teardown")
		return
	}
	ctx := t.Context()

	// Ensure the stack is destroyed at the end of the test
	terragrunt.StackRunContext(t, ctx, &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"destroy"},
	})
}
