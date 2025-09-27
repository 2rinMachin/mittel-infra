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

variable "ec2_key_name" {
  type        = string
  description = "Key name to give the EC2 instances"
  default     = "vockey"
}

variable "data_analysis_bucket_name" {
  type        = string
  description = "Name to give the bucket for data analysis"
  default     = "mittel-data-analysis-bucket"
}

variable "domain" {
  type        = string
  description = "Domain to use for SSL certificates"
}
