# Azure Terraform scripts

Sample terraform scripts for creating VMs (and associated resources) on Azure.

## Setup Steps

* Install the latest Azure CLI (python version). See the [Microsoft docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
 * On mac, the easiest way is to use brew: `brew install azure-cli`
* Set up Terraform:
 * For reference, see relevant [Terraform docs](https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html).
 * Connect the Azure CLI to your account by running `az login`. This will enable you to register the CLI as a "device" that has access to your Azure account subscription.
  * Note: If you have multiple subscriptions and don’t want to use your default subscription, you can tell terraform to use a specific subscription using command: `az account set --subscription=YOUR_SUBSCRIPTION_ID`.
* **Highly recommended**: If you want to use app specific credentials (client id, secret id) via Service Principal, you will need permissions to these for the app via Azure active directory. See [docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authenticate-service-principal-cli).
 * Note that after you create the service principal, you need to go into Resource Groups-->Access control (IAM), then add your app to that resource group as a Contributor.
* You can now run `terraform init` to initialize provider(s).

## Running Terraform Azure VM creation subscriptions

* There are many ways to specify Azure credentials to Terraform. These scripts use the following basic method:
 * Ensure an “azurerm” provider is included in your playbooks. These should reference credentials as variables.
 * The terraform variables file `variables.tf` initializes the variables.
 * To autopopulate these variables, you need a `credentials.auto.tfvars` file, which should contain your actual credential values and not be checked into any repo. See the associated Terraform [documentation about variables](https://www.terraform.io/intro/getting-started/variables.html).
 * For azure, the 4 credentials you need are:
  * Subscription_id
  * Client_id
  * Client_secret
  * Tenant_id
