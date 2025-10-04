variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
}

variable "subnet_a_id" {
  type        = string
  description = "The ID of the first subnet to use"
}

variable "subnet_b_id" {
  type        = string
  description = "The ID of the second subnet to use"
}

variable "databases_vm_private_ip" {
  type        = string
  description = "Private IP to give the databases VM"
}

variable "ec2_key_name" {
  type        = string
  description = "Key name to give the EC2 instances"
  default     = "vockey"
}

variable "data_analysis_bucket_name" {
  type        = string
  description = "Name to give the bucket for data analysis"
}

variable "domain" {
  type        = string
  description = "Domain to use for SSL certificates"
}

variable "frontend_repo" {
  type        = string
  description = "Repository URL for the frontend"
  default     = "https://github.com/2rinMachin/mittel-frontend"
}

variable "github_token" {
  type        = string
  description = "GitHub access token for the frontend"
}
