package helpers

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	infisical "github.com/infisical/go-sdk"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

const tgDir = "../../terragrunt/test/cluster"

type Suite struct {
	ClientSet         *kubernetes.Clientset
	KubeConfigOptions *k8s.KubectlOptions
}

func getInfisicalClient(t *testing.T) infisical.InfisicalClientInterface {
	ctx := t.Context()
	client := infisical.NewInfisicalClient(ctx, infisical.Config{
		SiteUrl: os.Getenv("INFISICAL_HOST"),
	})

	// Using the same environment variables for authentication as the Terraform provider
	_, err := client.Auth().UniversalAuthLogin(
		os.Getenv("INFISICAL_UNIVERSAL_AUTH_CLIENT_ID"),
		os.Getenv("INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET"),
	)

	if err != nil {
		t.Fatalf("Authentication failed: %v", err)
	}
	return client
}

func getKubeconfig(t *testing.T) string {
	client := getInfisicalClient(t)

	kubeconfig, err := client.Secrets().Retrieve(infisical.RetrieveSecretOptions{
		ProjectSlug: "iac",
		Environment: "main",
		SecretPath:  "/providers/kubeconfigs",
		SecretKey:   "TEST_KUBECONFIG",
	})

	if err != nil {
		t.Fatalf("Failed to retrieve kubeconfig secret from Infisical: %v", err)
	}

	return kubeconfig.SecretValue
}

func getKubeClientSet(t *testing.T, kubeconfig string) *kubernetes.Clientset {
	// Make clientset using the retrieved secrets
	config, err := clientcmd.RESTConfigFromKubeConfig([]byte(kubeconfig))
	if err != nil {
		t.Fatalf("Failed to create REST config from kubeconfig: %v", err)
	}

	cs, err := kubernetes.NewForConfig(config)
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

func getKubeConfigOptions(t *testing.T, kubeconfig string) *k8s.KubectlOptions {
	kubeconfigPath := t.TempDir() + "/kubeconfig"

	err := os.WriteFile(kubeconfigPath, []byte(kubeconfig), 0600)

	if err != nil {
		t.Fatalf("Failed to write kubeconfig to temporary file: %v", err)
	}

	return &k8s.KubectlOptions{
		ConfigPath: kubeconfigPath,
		Namespace:  "default",
	}
}

func NewSuite(t *testing.T) *Suite {
	kubeconfig := getKubeconfig(t)

	return &Suite{
		ClientSet:         getKubeClientSet(t, kubeconfig),
		KubeConfigOptions: getKubeConfigOptions(t, kubeconfig),
	}
}
