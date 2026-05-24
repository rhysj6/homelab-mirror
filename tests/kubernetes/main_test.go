package kubernetes_test

import (
	"testing"

	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	"github.com/rhysj6/homelab/tests/kubernetes/networking"
)

func TestKubernetesSuite(t *testing.T) {
	// SetupCluster(t)
	// Commented out during development to speed up test runs, but should be re-enabled to ensure proper cleanup of resources after tests are complete
	// defer TeardownCluster(t)
	s := helpers.NewSuite(t)
	t.Run("networking", func(t *testing.T) {
		networking.TestNetworking(t, s)
	})

}
