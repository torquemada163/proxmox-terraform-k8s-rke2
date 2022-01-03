# proxmox-terraform-k8s-rke2

Based on https://github.com/andreilapkin/tf-pve-k8s

## Preamble
One of the tasks of the Terraform script is to automatically create an inventory file for later launching Ansible playbooks. This is the main problem.
The Terraform provider Telmate/proxmox uses the `ssh_host` attribute to determine the IP address of instances.
## Installation
1. Copy content of **run_on_pve** folder to Proxmov VE
2. Copy your public SSH key file to Proxmox VE and remember name and location (i.e., `/root/user.pub`)
3. Login in to Proxmox VE and execute one or more copied script after configure setting it's settings:
```
will be added later
```
3. Install Terraform on your computer
4. Configure `env.tfvars.example` file and rename it to `env.tfvars`
5. Configure files `provider.tf`, `terraform.tf` if necessary.
6. Run for initialize Terraform:
```
terraform init -var-file env.tfvars
```
7. Run to plan:
```
terraform plan -var-file env.tfvars
```
8. Run to deploy:
```
terraform apply -var-file env.tfvars
```
**If you have slow SATA HDD and give errors about filelock, run deploy with only one executor:**
```
terraform apply -var-file env.tfvars -parallelism=1
```
9. Run to destroy:
```
terraform destroy -var-file env.tfvars
```
