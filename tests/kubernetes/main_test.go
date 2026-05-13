package kubernetes_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
)

func TestStack(t *testing.T) {

	ctx := t.Context()

	tgDir := "../../terragrunt/test/cluster"

	tgStackOpts := &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"apply"},
	}

	terragrunt.StackCleanContext(t, ctx, tgStackOpts)

	// Generate the test stack in it's folder
	terragrunt.StackGenerateContext(t, ctx, tgStackOpts)

	// Ensure the stack is destroyed at the end of the test
	defer terragrunt.StackRunContext(t, ctx, &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"destroy"},
	})

	terragrunt.StackRunContext(t, ctx, tgStackOpts)

}
