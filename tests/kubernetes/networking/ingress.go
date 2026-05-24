package networking

import (
	"context"
	"crypto/tls"
	"net"
	"net/http"
	"testing"
	"time"

	"github.com/rhysj6/homelab/tests/kubernetes/helpers"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
	testDomain = "ingress.test.homelab.example"
)

func testIngress(s *helpers.Suite) {
	ingresses, err := s.ClientSet.NetworkingV1().Ingresses("default").List(s.T.Context(), metav1.ListOptions{FieldSelector: "metadata.name=nginx"})
	if err != nil {
		s.T.Fatalf("Failed to list ingresses: %v", err)
	}

	if len(ingresses.Items) == 0 {
		s.T.Fatal("No nginx ingress found in the cluster")
	}

	ingress := ingresses.Items[0]
	ingressIP := ingress.Status.LoadBalancer.Ingress[0].IP

	s.T.Run("TestIngressGetIPs", func(t *testing.T) {
		if len(ingress.Status.LoadBalancer.Ingress) == 0 {
			t.Errorf("Ingress %s does not have an IP address assigned", ingress.Name)
		}
	})

	s.T.Run("TestIngressIsRoutable", func(t *testing.T) {

		// Using a custom HTTP client with a custom DialContext to bypass DNS resolution and route traffic directly to the ingress IP address, since the test domain won't resolve in the test environment
		url := "https://" + testDomain

		client := &http.Client{Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				// Redirect all DNS lookups for hostname to the actual ingress IP
				addr = ingressIP + ":443"
				return (&net.Dialer{}).DialContext(ctx, network, addr)
			},
		}}

		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			t.Fatalf("Failed to create HTTP request: %v", err)
		}

		response, err := client.Do(req)

		if err != nil {
			t.Fatalf("Failed to send HTTP request to ingress: %v", err)
		}

		if response.StatusCode != 200 {
			t.Errorf("Expected HTTP status code 200 but got %d", response.StatusCode)
		}
	})

	s.T.Run("TestIngressCertificate", func(t *testing.T) {
		url := ingressIP + ":443"

		conn, err := tls.Dial("tcp", url, &tls.Config{
			InsecureSkipVerify: true,
			ServerName:         testDomain,
		})
		if err != nil {
			t.Fatalf("Failed to connect to ingress at %s: %v", url, err)
		}
		defer conn.Close()

		certs := conn.ConnectionState().PeerCertificates
		if len(certs) == 0 {
			t.Fatal("No TLS certificates found for ingress")
		}

		cert := certs[0]
		if cert.Subject.CommonName != testDomain {
			t.Errorf("Expected certificate common name '%s' but got '%s'", testDomain, cert.Subject.CommonName)
		}

		// Check all certs in chain have valid expiry dates
		for _, cert := range certs {
			if cert.NotBefore.After(time.Now()) {
				t.Errorf("Certificate is not valid yet: NotBefore %v is in the future", cert.NotBefore)
			}
			if cert.NotAfter.Before(time.Now()) {
				t.Errorf("Certificate has expired: NotAfter %v is in the past", cert.NotAfter)
			}
		}
	})

}
