package networking

import (
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
)

func TestNetworking(s *helpers.Suite) {
	manifestPath := helpers.FixturePath(s.T, "networking", "nginx.yaml")
	k8s.KubectlApplyContext(s.T, s.T.Context(), s.KubeConfigOptions, manifestPath)
	defer k8s.KubectlDeleteContext(s.T, s.T.Context(), s.KubeConfigOptions, manifestPath)

	// Wait for the nginx deployment to be ready before proceeding with the test
	k8s.WaitUntilDeploymentAvailableContext(s.T, s.T.Context(), s.KubeConfigOptions, "nginx", 60, 5*time.Second)

	testPodNetworking(s)
	testLoadBalancers(s)
	testIngress(s)
}
