variable "aws_region" {
  description = "Region for the VPC"
  default     = "eu-west-1"
}

variable "peer_owner_id" {
  description = "AWS Account ID dev or prod"
}

variable "peer_vpc_id" {
  description = "Acceptors VPC-ID"
}

variable "peer_cidr_block" {
  description = "Acceptors VPC Cidr Range"
}

variable "requester_environment" {
  description = "Environment Name of Times Saving API"
}

variable "accepter_environment" {
  description = "Environment Name of nu-ce-saving-api"
}

variable "s3_bucket" {
  description = "S3 bucket to store terraform state"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
}

variable "public_subnet_cidr_1" {
  description = "CIDR for the Public Subnet"
}

variable "public_subnet_cidr_2" {
  description = "CIDR for the Public Subnet"
}

variable "public_subnet_cidr_3" {
  description = "CIDR for the Public Subnet"
}

variable "private_subnet_cidr_1" {
  description = "CIDR for the Private Subnet"
}

variable "private_subnet_cidr_2" {
  description = "CIDR for the Private Subnet"
}

variable "private_subnet_cidr_3" {
  description = "CIDR for the Private Subnet"
}

variable "hosted_zone_id" {
  description = "HostedZone ID"
}
variable "hosted_zone_name" {
  description = "HostedZone Name"
}

variable "environment" {
  description = "Environment Name of Saving API VPC"
}

variable "cluster_instance_count" {
  description = "Number of instances inside Aurora cluster"
}

variable "cluster_instance_size" {
  description = "Instance type/size inside Aurora cluster"
}

variable "master_cluster_username" {
  description = "Aurora Cluster master username"
}

variable "ssh_key_name" {
  description = "SSH key to access bastion host"
}

variable "acs_db_server_name" {
  description = "ACS DB endpoint for DMS"
}

variable "acs_username" {
  description = "ACS DB username for DMS"
}
variable "acs_db_environment" {
  description = "ACS DB Environment"
}

variable "is_prod" {
  description = "Is set to 1 if the environment is production, 0 otherwise. Useful to create resources conditionally with the count attribute in resources"
}

variable "transit_gateway_id" {
  description = "The Transit Gateway used by both EKS and RDS"
}

variable "eks_cidr_block" {
  description = "The CIDR range for the EKS cluster"
}
