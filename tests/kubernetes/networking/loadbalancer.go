package networking

import (
	"net/http"
	"testing"

	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func testLoadBalancer(t *testing.T, s *helpers.Suite) {
	// Tests that the automatically provisioned load balancers have IP addresses assigned to them
	t.Run("hasIP", func(t *testing.T) {
		// Get the list of load balancers in the cluster in all namespaces
		lbs, err := s.ClientSet.CoreV1().Services("").List(t.Context(), metav1.ListOptions{
			FieldSelector: "spec.type=LoadBalancer",
		})
		if err != nil {
			t.Fatalf("Failed to list load balancers: %v", err)
		}

		if len(lbs.Items) == 0 {
			t.Fatal("No load balancers found in the cluster")
		}

		for _, lb := range lbs.Items {
			if len(lb.Status.LoadBalancer.Ingress) == 0 {
				t.Errorf("Load balancer %s in namespace %s does not have an IP address assigned", lb.Name, lb.Namespace)
			}
		}
	})

	t.Run("isRoutable", func(t *testing.T) {
		service, err := s.ClientSet.CoreV1().Services("default").Get(t.Context(), "nginx-external", metav1.GetOptions{})
		if err != nil {
			t.Fatalf("Failed to get service: %v", err)
		}
		lpbIP := service.Status.LoadBalancer.Ingress[0].IP

		url := "http://" + lpbIP
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			t.Fatalf("Failed to create HTTP request: %v", err)
		}

		client := &http.Client{}
		response, err := client.Do(req)

		if err != nil {
			t.Fatalf("Failed to send HTTP request to %s: %v", url, err)
		}

		if response.StatusCode != 200 {
			t.Errorf("Expected HTTP status code 200 but got %d", response.StatusCode)
		}
	})
}
