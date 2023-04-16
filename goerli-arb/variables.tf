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
