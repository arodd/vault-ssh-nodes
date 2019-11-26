variable "ami_prefix" {
  default     = "is-aws-immutable-vault-"
  description = "AMI prefix name(From Packer) to target in the filter"
}

variable "ami_release" {
  default     = "0.0.1"
  description = "AMI release version to target in the filter"
}

variable "ami_os" {
  default     = "centos"
  description = "AMI operating system to target in the filter"
}

variable "ami_os_release" {
  default     = "7"
  description = "AMI OS version to target in the filter"
}

variable "name_prefix" {
  default     = "hashicorp"
  description = "prefix used in resource names"
}

variable "key_name" {
  default     = "default"
  description = "SSH key name for Vault and Consul instances"
}

variable "web_subnet" {
  description = "subnet for web nodes"
}

variable "app_subnet" {
  description = "subnet for app nodes"
}

variable "bastion_subnet" {
  description = "subnet for bastion host"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "owner" {
  description = "value of owner tag on EC2 instances"
}

variable "ttl" {
  description = "value of ttl tag on EC2 instances"
}
