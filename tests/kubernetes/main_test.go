package kubernetes_test

import (
	"testing"

	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	"github.com/rhysj6/homelab/tests/kubernetes/networking"
)

func TestKubernetesSuite(t *testing.T) {
	helpers.SetupCluster(t)
	defer helpers.TeardownCluster(t)
	s := helpers.NewSuite(t)
	t.Run("networking", func(t *testing.T) {
		networking.TestNetworking(t, s)
	})

}
