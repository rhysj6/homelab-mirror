package kubernetes_test

import (
	"testing"
)

func TestMain(t *testing.T) {
	SetupCluster(t)
	// Commented out during development to speed up test runs, but should be re-enabled to ensure proper cleanup of resources after tests are complete
	// defer TeardownCluster(t)
	s := NewSuite(t)
	s.TestLoadBalancers()

}
