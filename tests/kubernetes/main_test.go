package kubernetes_test

import (
	"testing"

	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	networking_test "github.com/rhysj6/homelab/tests/kubernetes/networking"
)

func TestMain(t *testing.T) {
	// SetupCluster(t)
	// Commented out during development to speed up test runs, but should be re-enabled to ensure proper cleanup of resources after tests are complete
	// defer TeardownCluster(t)
	s := helpers.NewSuite(t)
	networking_test.TestNetworking(s)

}
