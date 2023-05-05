# Terraform PAN-OS Firewall Configuration

This Terraform project manages PAN-OS firewall configurations. It is divided into three separate modules to manage network, object, and policy configurations.

## Modules

### Network Module

The network module is responsible for configuring:

- Ethernet interfaces
- Security zones
- Virtual router

### Object Module

The object module is responsible for configuring:

- Administrative tags
- Address objects

### Policy Module

The policy module is responsible for configuring:

- Security policies

## Usage

1. Install Terraform.
2. Clone this repository.
3. Update the `terraform.tfvars` file with your PAN-OS firewall hostname, username, and password.
4. Run `terraform init` to initialize the Terraform project.
5. Run `terraform plan` to view the planned changes.
6. Run `terraform apply` to apply the changes to your PAN-OS firewall.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
