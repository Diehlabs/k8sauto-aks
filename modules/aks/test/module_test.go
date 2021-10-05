package test

import (
	"testing"
	// "fmt"
	// "time"
	// "strings"
	//test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	//"github.com/gruntwork-io/terratest/modules/ssh"
	//"github.com/gruntwork-io/terratest/modules/retry"
	//"github.com/gruntwork-io/terratest/modules/aks"
)

var clusterName = "aks_module_test-$(Build.BuildId)-westus-test"

func TestTerraformModule(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../examples/build",
		// Using token replacement in AZDO to set the path for the Terraform binary.
		// We download it to the temp dir on each run so that it's wiped out afterwards.
		TerraformBinary: "$(Agent.TempDirectory)/terraform",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	outputClusterName := terraform.Output(t, terraformOptions, "cluster_name")
	assert.Equal(t, clusterName, outputClusterName)
}

// func sshToPrivateHost(t *testing.T) {
// 	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
// 		// Set the path to the Terraform code that will be tested.
// 		TerraformDir: "../build",
// 		// Using token replacement in AZDO to set the path for the Terraform binary.
// 		// We download it to the temp dir on each run so that it's wiped out afterwards.
// 		TerraformBinary: "$(Agent.TempDirectory)/terraform",
// 	})

// 	keyPair := ssh.KeyPair{
// 		PublicKey: terraform.Output(t, terraformOptions, "ssh_public_key"),
// 		PrivateKey: terraform.Output(t, terraformOptions, "ssh_private_key"),
// 	}

// 	sshHost := ssh.Host{
// 		Hostname: terraform.Output(t, terraformOptions, "cluster_fqdn"),
// 		SshUserName: terraform.Output(t, terraformOptions, "admin_user_name"),
// 		SshKeyPair: &keyPair,
// 	}

// 	ssh.CheckSshConnection(t, sshHost)

// clusterFqdn := terraform.Output(t, terraformOptions, "cluster_fqdn")
// adminName := terraform.Output(t, terraformOptions, "admin_user_name")
// adminKey := terraform.Output(t, terraformOptions, "admin_ssh_key")

// It can take a minute or so for the Instance to boot up, so retry a few times
// maxRetries := 30
// timeBetweenRetries := 5 * time.Second
// description := fmt.Sprintf("SSH to cluster %s", clusterFqdn)

// // Run a simple echo command on the server
// expectedText := "Hello, World"
// command := fmt.Sprintf("echo -n '%s'", expectedText)

// // Verify that we can SSH to the Instance and run commands
// retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
// 	actualText, err := ssh.CheckPrivateSshConnectionE(t, publicHost, privateHost, command)

// 	if err != nil {
// 		return "", err
// 	}

// 	if strings.TrimSpace(actualText) != expectedText {
// 		return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
// 	}

// 	return "", nil
// })
//}
