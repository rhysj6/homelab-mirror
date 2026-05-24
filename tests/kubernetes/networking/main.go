package networking_test

import (
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
)

func TestNetworking(s *helpers.Suite) {
	k8s.KubectlApplyContext(s.T, s.T.Context(), s.KubeConfigOptions, "fixtures/networking/nginx.yaml")
	defer k8s.KubectlDeleteContext(s.T, s.T.Context(), s.KubeConfigOptions, "fixtures/networking/nginx.yaml")

	// Wait for the nginx deployment to be ready before proceeding with the test
	k8s.WaitUntilDeploymentAvailableContext(s.T, s.T.Context(), s.KubeConfigOptions, "nginx", 60, 1*time.Second)

	testLoadBalancers(s)
	testIngress(s)
}
