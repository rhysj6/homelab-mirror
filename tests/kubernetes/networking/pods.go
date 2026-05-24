package networking

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func testPods(t *testing.T, s *helpers.Suite) {
	manifestPath := helpers.FixturePath(t, "networking", "client.yaml")
	k8s.KubectlApplyContext(t, t.Context(), s.KubeConfigOptions, manifestPath)
	defer k8s.KubectlDeleteContext(t, t.Context(), s.KubeConfigOptions, manifestPath)

	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), s.KubeConfigOptions, "client", 60, 1*time.Second)

	pods := k8s.ListPodsContext(t, t.Context(), s.KubeConfigOptions, metav1.ListOptions{
		LabelSelector: "app=client",
	})

	if len(pods) == 0 {
		t.Fatal("No client pods found in the cluster")
	}

	pod := pods[0]

	t.Run("canConnectToService", func(t *testing.T) {
		cmd := []string{"wget", "-q", "-O", "/dev/null", "http://nginx-internal.default.svc.cluster.local/"}

		k8s.ExecPodContext(t, t.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

	t.Run("canConnectToLocalNetwork", func(t *testing.T) {
		// Connecting to router IP to test that pods can route traffic to the local network
		cmd := []string{"wget", "-q", "-O", "/dev/null", "--no-check-certificate", "https://10.0.0.1/"}

		k8s.ExecPodContext(t, t.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

	t.Run("canConnectToExternalNetwork", func(t *testing.T) {
		cmd := []string{"wget", "-q", "-O", "/dev/null", "https://www.google.com/"}

		k8s.ExecPodContext(t, t.Context(), s.KubeConfigOptions, pod.Name, "", cmd...)
	})

}
