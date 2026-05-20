package kubernetes_test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
	infisical "github.com/infisical/go-sdk"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

const tgDir = "../../terragrunt/test/cluster"

type Suite struct {
	ClientSet *kubernetes.Clientset
	t         *testing.T
}

func SetupCluster(t *testing.T) {
	ctx := t.Context()

	tgStackOpts := &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"apply"},
	}

	// Clean and generate the terragrunt stack before running the test
	terragrunt.StackCleanContext(t, ctx, tgStackOpts)
	terragrunt.StackGenerateContext(t, ctx, tgStackOpts)

	terragrunt.StackRunContext(t, ctx, tgStackOpts)
}

func TeardownCluster(t *testing.T) {
	ctx := t.Context()

	// Ensure the stack is destroyed at the end of the test
	terragrunt.StackRunContext(t, ctx, &terragrunt.Options{
		TerragruntDir: tgDir,
		TerraformArgs: []string{"destroy"},
	})
}

func getInfisicalClient(t *testing.T) infisical.InfisicalClientInterface {
	ctx := t.Context()
	client := infisical.NewInfisicalClient(ctx, infisical.Config{
		SiteUrl:          os.Getenv("INFISICAL_URL"),
		AutoTokenRefresh: true,
	})

	// Using the same environment variables for authentication as the Terraform provider
	_, err := client.Auth().UniversalAuthLogin(
		os.Getenv("UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_ID"),
		os.Getenv("UNIVERSAL_AUTH_MACHINE_IDENTITY_CLIENT_SECRET"),
	)

	if err != nil {
		fmt.Printf("Authentication failed: %v", err)
		os.Exit(1)
	}
	return client
}

func getKubeClientSet(t *testing.T) *kubernetes.Clientset {
	client := getInfisicalClient(t)

	host, err := client.Secrets().Retrieve(infisical.RetrieveSecretOptions{
		ProjectSlug: "iac",
		Environment: "main",
		SecretPath:  "/providers/kubeconfigs",
		SecretKey:   "TEST_HOST",
	})
	if err != nil {
		t.Fatalf("Failed to retrieve kubernetes host secret from Infisical: %v", err)
	}

	ca_cert, err := client.Secrets().Retrieve(infisical.RetrieveSecretOptions{
		ProjectSlug: "iac",
		Environment: "main",
		SecretPath:  "/providers/kubeconfigs",
		SecretKey:   "TEST_CLUSTER_CA_CERTIFICATE",
	})
	if err != nil {
		t.Fatalf("Failed to retrieve CA certificate secret from Infisical: %v", err)
	}

	client_cert, err := client.Secrets().Retrieve(infisical.RetrieveSecretOptions{
		ProjectSlug: "iac",
		Environment: "main",
		SecretPath:  "/providers/kubeconfigs",
		SecretKey:   "TEST_CLIENT_CERTIFICATE",
	})
	if err != nil {
		t.Fatalf("Failed to retrieve client certificate secret from Infisical: %v", err)
	}

	client_key, err := client.Secrets().Retrieve(infisical.RetrieveSecretOptions{
		ProjectSlug: "iac",
		Environment: "main",
		SecretPath:  "/providers/kubeconfigs",
		SecretKey:   "TEST_CLIENT_KEY",
	})
	if err != nil {
		t.Fatalf("Failed to retrieve client key secret from Infisical: %v", err)
	}

	// Make clientset using the retrieved secrets
	cs, err := kubernetes.NewForConfig(&rest.Config{
		Host: host.SecretValue,
		TLSClientConfig: rest.TLSClientConfig{
			CAData:   []byte(ca_cert.SecretValue),
			CertData: []byte(client_cert.SecretValue),
			KeyData:  []byte(client_key.SecretValue),
		},
	})

	if err != nil {
		t.Fatalf("Failed to create Kubernetes clientset: %v", err)
	}

	// Quick test to ensure the clientset can connect to the cluster
	_, err = cs.ServerVersion()
	if err != nil {
		t.Fatalf("Failed to connect to Kubernetes cluster: %v", err)
	}

	return cs
}

func NewSuite(t *testing.T) *Suite {
	return &Suite{
		ClientSet: getKubeClientSet(t),
		t:         t,
	}
}
