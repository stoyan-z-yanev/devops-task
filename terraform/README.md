# Terraform VPC templates

Note: This is something which I have written some time ago, for a smaller project. Now I would definately split it into terraform modules - vpc, rds, dashboards.


## VPC structure (dev example)

The VPC range we use is 10.200.0.0/16

Public subnets ips: `10.200.1.0/24 10.200.2.0/24 10.200.3.0/24`
Private subnets ips: Public subnets ips: `10.200.11.0/24 10.200.12.0/24 10.220.13.0/24`

### Basic Templates overview

Templates are creating VPC with public/private subnets with two routing tables again public and private. Private routing table uses NAT Gateway to route out and instances placed in any private subnets can only be accessed through instance within public subnet. With the current setting the elastic IP is manually created and the Allocation ID is used to assign it to the Gateway. It can be modified inside `vpc.tf` template. Both `NatGatewayAllocID` and `NatGatewayEIP` need to be modified based on the account we are going to spin up the new stacks.

The S3 buckets where we store backup state: `times-saving-api-dev`.
The dynamodb we use to store locks: `terraform-lock-saving-api-dev`.

## Validating terraform templates

```bash
terraform validate
```

## Plan terraform templates

Dev VPC

```bash
terraform plan -var-file=dev_env.tfvars
```

## Deploy terraform templates

Dev VPC

```bash
terraform apply -var-file=dev_env.tfvars
```

Note: make sure you have correct credentials set for aws when deploying from local.

## Connect to Aurora Cluster

Jump onto Bastian Host

```bash
ssh -i TNLDefault.key ubuntu@<public-ip-bastian-host
```

Switch user to postgres

```bash
sudo su - postgres
```

Connect to Aurora

```bash
psql -h myhost -d mydb -U myuser

# example
psql -h saving-api-dev.dev.thetimes.works -p 5432 -d saving_api_dev -U DEVusername
# you will be prompted for a password
```

Passwords for Aurora clusters are stored in Parameter store in AWS

* Dev account contains `/saving-api/dev/cluster_password` and `/saving-api/uat/cluster_password`.
* Prod account contains `/saving-api/staging/cluster_password` and `/saving-api/prod/cluster_password`.
  With correct permissions you can reveal the value for encrypted parameter.
