package kubernetes_test

import (
	"testing"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func (s *Suite) TestLoadBalancers() {
	// Tests that the automatically provisioned load balancers have IP addresses assigned to them
	s.t.Run("TestLoadBalancersGetIPs", func(t *testing.T) {
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
			} else {
				t.Logf("Load balancer %s in namespace %s has IP address: %s", lb.Name, lb.Namespace, lb.Status.LoadBalancer.Ingress[0].IP)
			}
		}
	})
}
