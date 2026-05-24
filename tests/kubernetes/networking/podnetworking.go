package networking

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func testPodNetworking(s *helpers.Suite) {
	manifestPath := helpers.GetFixturePath(s.T, "networking", "client.yaml")
	k8s.KubectlApplyContext(s.T, s.T.Context(), s.KubeConfigOptions, manifestPath)
	defer k8s.KubectlDeleteContext(s.T, s.T.Context(), s.KubeConfigOptions, manifestPath)

	k8s.WaitUntilDeploymentAvailableContext(s.T, s.T.Context(), s.KubeConfigOptions, "client", 60, 1*time.Second)

	pods := k8s.ListPodsContext(s.T, s.T.Context(), s.KubeConfigOptions, metav1.ListOptions{
		LabelSelector: "app=client",
	})

	if len(pods) == 0 {
		s.T.Fatal("No client pods found in the cluster")
	}

	pod := pods[0]

	s.T.Run("TestPodToServiceConnectivity", func(t *testing.T) {
		cmd := []string{"wget", "-q", "-O", "/dev/null", "http://nginx-internal.default.svc.cluster.local/"}

		k8s.ExecPodContext(s.T, s.T.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

	s.T.Run("TestPodToLocalNetworkConnectivity", func(t *testing.T) {
		// Connecting to router IP to test that pods can route traffic to the local network
		cmd := []string{"wget", "-q", "-O", "/dev/null", "--no-check-certificate", "https://10.0.0.1/"}

		k8s.ExecPodContext(s.T, s.T.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

	s.T.Run("TestPodToExternalNetworkConnectivity", func(t *testing.T) {
		cmd := []string{"wget", "-q", "-O", "/dev/null", "https://www.google.com/"}

		k8s.ExecPodContext(s.T, s.T.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

}
