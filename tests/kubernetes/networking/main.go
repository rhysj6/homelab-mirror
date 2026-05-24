package networking

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
)

func TestNetworking(t *testing.T, s *helpers.Suite) {
	manifestPath := helpers.FixturePath(t, "networking", "nginx.yaml")
	k8s.KubectlApplyContext(t, t.Context(), s.KubeConfigOptions, manifestPath)
	defer k8s.KubectlDeleteContext(t, t.Context(), s.KubeConfigOptions, manifestPath)

	// Wait for the nginx deployment to be ready before proceeding with the test
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), s.KubeConfigOptions, "nginx", 60, 5*time.Second)

	t.Run("pods", func(t *testing.T) {
		testPods(t, s)
	})

	t.Run("loadBalancer", func(t *testing.T) {
		testLoadBalancer(t, s)
	})

	t.Run("ingress", func(t *testing.T) {
		testIngress(t, s)
	})
}
