# How to structure a Terraform project for PAN-OS firewalls

## Introduction

Welcome to this tutorial on managing the configuration of PAN-OS firewalls using Terraform! Terraform is an infrastructure-as-code (IaC) tool that allows you to define, provision, and manage infrastructure in a declarative manner. In this tutorial, we will use the "panos" Terraform provider from Palo Alto Networks to configure and manage a PAN-OS firewall.

We will walk through the process of setting up a Terraform project, creating modules for network, policy, and object configurations, and using provisioners to execute custom commands. By the end of this tutorial, you will have a better understanding of how to use Terraform to manage PAN-OS firewalls.

## Prerequisites

Before diving into the Terraform project, make sure you have the following prerequisites in place:

1. A basic understanding of Terraform and its syntax
2. Terraform installed on your local machine (version 0.13 or higher)
3. A Palo Alto Networks PAN-OS firewall with the necessary API access enabled
4. The "panos" Terraform provider installed and configured
5. Python installed on your local machine (for running the dynamic data script).

To install the "panos" provider, add the following code to your Terraform configuration file:

```hcl
terraform {
  required_providers {
    panos = {
      source  = "paloaltonetworks/panos"
      version = "1.11.1"
    }
  }
}
```

After adding the provider configuration, run `terraform init` to download and install the "panos" provider.

## Understanding a Terraform project's structure

To effectively manage PAN-OS firewall configurations using Terraform, it is essential to understand the structure of a Terraform project. There are two primary structures you can use: a simple structure or a complex structure. The choice depends on the size of your project and the level of flexibility you require.

### Simple Structure

In a simple structure, you keep all Terraform configuration files in a single directory. This setup is easy to manage and suitable for small projects with minimal configuration. Your directory may include files such as:

- [main.tf](./main.tf): Contains the primary configuration for your project
- [variables.tf](./variables.tf): Defines the input variables used in your configuration
- [outputs.tf](./outputs.tf): Specifies the outputs from your configuration
- [terraform.tfvars](./terraform.tfvars): Contains the values for the input variables

### Complex Structure

For larger projects with multiple resources and modules, a complex structure is more appropriate. It organizes your project into separate directories, each containing its Terraform configuration files. This structure offers more flexibility and promotes code reusability. A typical complex structure may include:

- modules: A directory containing reusable modules for your project (e.g., network, policy, and object modules)
- environments: A directory containing environment-specific configurations (e.g., dev, staging, and prod)
- global: A directory containing global resources and configurations

## Step 1 - Setting up your initial project

To begin managing PAN-OS firewall configurations with Terraform, start by setting up your initial project:

1. Install Terraform: Ensure you have Terraform installed on your machine. If not, download and install it from the official website: https://www.terraform.io/downloads.html

2. Create a new directory: Create a new directory for your project and navigate to it in the command prompt or terminal.

3. Initialize Terraform: Run terraform init in your project directory. This command initializes your project and downloads the required provider plugins, including the "panos" provider from Palo Alto Networks.

4. Configure the "panos" provider: In your project directory, create a main.tf file and configure the "panos" provider with your PAN-OS firewall credentials, like so:

    ```hcl
    terraform {
        required_providers {
            panos = {
            source  = "paloaltonetworks/panos"
            version = "1.11.1"
            }
        }
    }

    provider "panos" {
        hostname = var.panos_hostname
        username = var.panos_username
        password = var.panos_password
    }
    ```

5. Define input variables: Create a variables.tf file to define the input variables for the PAN-OS firewall hostname, username, and password:

    ```hcl
    variable "panos_hostname" {
        description = "The hostname of the PAN-OS firewall."
    }

    variable "panos_username" {
        description = "The username for the PAN-OS firewall."
    }

    variable "panos_password" {
        description = "The password for the PAN-OS firewall."
    }
    ```

6. Save your changes and run terraform init again to ensure the provider configuration is properly loaded.

Now your initial project is set up and ready for further configuration.

## Step 2 - Creating a Python Script for Dynamic Data

In some cases, you may need to retrieve dynamic data from an external source to use in your Terraform configuration. For this, you can use a Python script that queries the data and outputs it in a format that Terraform can consume.

1. Create a new file named get_dynamic_data.py in your project directory.

2. Add the necessary imports and implement a function that retrieves the dynamic data from your external source. For example:

    ```python
    import json
    import requests

    def get_dynamic_data():
        # Replace the URL with your external data source
        url = "https://example.com/api/dynamic-data"
        response = requests.get(url)

        if response.status_code == 200:
            return response.json()
        else:
            raise Exception("Failed to fetch dynamic data")

    if __name__ == "__main__":
        dynamic_data = get_dynamic_data()
        print(json.dumps(dynamic_data))
    ```

3. In your main.tf file, add a local_file resource that calls the Python script and stores its output in a JSON file:

    ```hcl
    resource "local_file" "dynamic_data" {
        content  = jsonencode(data.external.dynamic_data.result)
        filename = "${path.module}/dynamic_data.json"
    }

    data "external" "dynamic_data" {
        program = ["python", "${path.module}/get_dynamic_data.py"]
    }

    ```

4. Now you can use the dynamic data in your Terraform configuration by referencing the local_file.dynamic_data resource and its attributes.

With this setup, you can dynamically retrieve data from an external source and use it in your Terraform configuration to manage your PAN-OS firewall.

## Step 3 - Defining the Firewall Configuration

Now, let's define the PAN-OS firewall configuration using the `panos` Terraform provider. In your main.tf file, add the necessary configuration blocks for your firewall:

1. Configure the PAN-OS provider:

    ```hcl
    provider "panos" {
        hostname     = var.hostname
        username     = var.username
        password     = var.password
    }
    ```

2. Create a resource block for your firewall configuration, such as an Ethernet interface:

    ```hcl
    resource "panos_ethernet_interface" "example" {
        name        = "ethernet1/1"
        mode        = "layer3"
        vsys        = "vsys1"
        ip          = "192.168.1.1/24"
        enable_dhcp = false
    }
    ```

3. Configure the necessary resources for your firewall, such as interfaces, zones, and policies. For example:

    ```hcl
    resource "panos_address_object" "example" {
        name        = "Example-Address-Object"
        value       = "10.0.0.1"
        description = "Example address object"
    }

    resource "panos_security_rule" "allow_inbound" {
        rule_name           = "Allow Inbound Traffic"
        action              = "allow"
        source_zone         = ["Untrust"]
        destination_zone    = ["Trust"]
        source_address      = ["any"]
        destination_address = ["any"]
        application         = ["any"]
        service             = ["application-default"]
        log_setting         = "default"
    }
    ```

4. Continue to add resource blocks for your firewall configuration according to your needs.

By defining the firewall configuration using Terraform, you can manage and automate the configuration of your PAN-OS firewall in a declarative and version-controlled manner.

## Step 4 - Creating modules

To better manage your PAN-OS firewall configuration, you can organize your code into modules, such as "network", "policy", and "object". Modules make it easier to maintain and reuse code.

Create separate directories for each module within your project, such as modules/network, modules/policy, and modules/object.

Within each module directory, create a main.tf file and move the relevant resource blocks from your root main.tf file to their respective module main.tf files.

For example, for the "network" module, your modules/network/main.tf file might look like this:

```hcl
terraform {
  required_providers {
    panos = {
      source  = "paloaltonetworks/panos"
      version = "1.11.1"
    }
  }
}

resource "panos_ethernet_interface" "example" {
  name        = "ethernet1/1"
  mode        = "layer3"
  vsys        = "vsys1"
  ip          = "192.168.1.1/24"
  enable_dhcp = false
}
```

For the "objects" module, your modules/objects/main.tf file might look like this:

```hcl
terraform {
  required_providers {
    panos = {
      source  = "paloaltonetworks/panos"
      version = "1.11.1"
    }
  }
}

resource "panos_address_object" "example" {
  name        = "Example-Address-Object"
  value       = "10.0.0.1"
  description = "Example address object"
}
```

For the "policy" module, your modules/policy/main.tf file might look like this:

```hcl
terraform {
  required_providers {
    panos = {
      source  = "paloaltonetworks/panos"
      version = "1.11.1"
    }
  }
}

resource "panos_security_rule" "allow_inbound" {
  rule_name           = "Allow Inbound Traffic"
  action              = "allow"
  source_zone         = ["Untrust"]
  destination_zone    = ["Trust"]
  source_address      = ["any"]
  destination_address = ["any"]
  application         = ["any"]
  service             = ["application-default"]
  log_setting         = "default"
}
```

After moving the resource blocks to their respective module directories, use the module block in your root main.tf file to call these modules:

```hcl
module "network" {
  source = "./modules/network"
  providers = {
    panos = panos
  }
}

module "policy" {
  source = "./modules/policy"
  providers = {
    panos = panos
  }
}

module "object" {
  source = "./modules/objects"
  providers = {
    panos = panos
  }
}
```

This way, your PAN-OS firewall configuration will be well-organized and easier to maintain.

## Step 5 - Planning and Applying the Configuration

Before applying your configuration, it's a good idea to run the terraform init command to initialize your Terraform workspace. This command downloads the necessary provider plugins and sets up the backend for storing your state:

```bash
terraform init
```

Next, run the terraform plan command to review the changes Terraform will make to your PAN-OS firewall:

```bash
terraform plan
```

The plan command will output a detailed list of the resources Terraform will create, modify, or delete. Carefully review the plan to ensure it aligns with your desired configuration.

If you're satisfied with the plan, apply your configuration by running the terraform apply command:

```bash
terraform apply
```

Terraform will prompt you to confirm that you want to apply the changes. Type yes and press Enter to proceed. Terraform will create, modify, or delete resources as specified in your plan.

Remember to store the Terraform state file securely, as it contains sensitive information about your infrastructure.

## Step 6 - Running code using provisioners

In some cases, you may need to run additional scripts or commands after the configuration has been applied. Terraform supports this through the use of provisioners.

For instance, if you need to commit the changes on the PAN-OS firewall after the configuration is applied, you can use the local-exec provisioner within your Terraform configuration:

```hcl
resource "null_resource" "commit_changes" {
  depends_on = [module.network, module.policy, module.object]

  provisioner "local-exec" {
    command = "go run scripts/firewall-commit.go -auth auth.json"
  }
}
```

In this example, the local-exec provisioner will execute the specified Go script on your local machine after the PAN-OS configuration is successfully applied. The script will commit the changes on the firewall. Make sure to include the depends_on attribute to specify the order of execution and ensure that the script runs after the necessary resources are created.

Be cautious when using provisioners, as they can lead to complex and difficult-to-maintain configurations. Only use them when absolutely necessary and when there are no alternatives available within the Terraform provider itself.

## Step 7 - Committing configuration with a Go script

In the previous step, we used a Go script to commit the changes on the PAN-OS firewall. The script is located in the scripts directory and is named firewall-commit.go. It uses the Pango library to interact with the PAN-OS firewall and perform the commit operation.

The script reads the authentication details (hostname, username, and password) from an external JSON file specified by the -auth flag. It then connects to the firewall, performs the commit, and outputs the result.

To use the script, you need to have Go installed on your machine and provide the path to the authentication JSON file. The JSON file should contain the following structure:

```json
{
  "hostname": "<your-firewall-hostname>",
  "username": "<your-username>",
  "password": "<your-password>"
}
```

You can run the script using the following command:

```bash
go run scripts/firewall-commit.go -auth auth.json
```

The script will output the result of the commit operation, indicating whether it was successful or if there were any errors.

## Conclusion

In this blog post, we've explored how to manage the configuration of PAN-OS firewalls using the "panos" Terraform provider from Palo Alto Networks. We covered the setup of a Terraform project, the creation of Python scripts for dynamic data, defining the firewall configuration, creating modules, and applying the configuration using Terraform. Additionally, we discussed how to run additional code using provisioners and how to commit the configuration changes using a Go script.

By leveraging the power of Terraform and the "panos" provider, you can automate and simplify the management of your PAN-OS firewall configurations, enabling you to maintain consistency and reduce the potential for human error.
