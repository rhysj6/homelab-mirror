package helpers

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
)

func SetupCluster(t *testing.T) {
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
	ctx := t.Context()

	// Ensure the stack is destroyed at the end of the test
	terragrunt.StackRunContext(t, ctx, &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"destroy"},
	})
}
