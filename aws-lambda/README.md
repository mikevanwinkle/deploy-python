# Terraform lambda example

Update the values in `vars/dev.tfvars` to match your needs.

Configure your aws credentials as documented here.

Install terraform with `brew install terraform` or the package manager of your choice

NOTE: This example assumes that you have a registered domain that is managed by AWS. You can still use the example if this is not 
the case but you will need to remove the references to the domain

Run terraform:
```
terraform init
terraform apply
```

