variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
  default = ""
}

# Required
variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
  default = ""
}

variable "aws_session_token" {
  type        = string
  description = "AWS session token used to create AWS infrastructure"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "eu-west-3"
}

variable "aws_zone" {
  type        = string
  description = "AWS zone used for all resources"
  default     = "eu-west-3a"
}

variable "instance_type" {
  type        = string
  description = "Instance type used for all EC2 instances"
  default     = "t3.medium"
}

variable "instance_ami" {
  type = string
  description = "AMI to use for EC2 instances"
  # ubuntu 20.04
  default = "ami-01a3ab628b8168507"
}

variable "key_pair_name" {
  type = string
  description = "Keypair name"
  default = "chance2"
}

variable "mysql_password" {
  type = string
  description = "sql database password"
}

variable "develop_kubernetes_token" {
  type = string
  description = "Kubernetes connection token for develop cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use"
  default     = "v1.24.12+k3s1"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "v1.11.1"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format: v0.0.0)"
  default     = "2.7.1"
}

variable "rancher_helm_repository" {
  type        = string
  description = "The helm repository, where the Rancher helm chart is installed from"
  default     = "https://releases.rancher.com/server-charts/latest"
}

# Required
variable "rancher_server_admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap"
  default = "password"
}

# Local variables used to reduce repetition
locals {
  node_username = "ubuntu"
}
