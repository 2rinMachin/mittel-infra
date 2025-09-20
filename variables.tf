variable "labrole_arn" {
  type        = string
  description = "The ARN of the LabRole to use as execution role"
  default     = "arn:aws:iam::592582443043:role/LabRole"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
  default     = "vpc-0208045d05ce79bde"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to assign the services"
  default = [
    "subnet-08a37c79da69b4e9b",
    "subnet-0c56bc91dcfa1b4d6",
    "subnet-0dd3ed575a8bd6604",
    "subnet-0ed4a5d99b66e8b1b",
    "subnet-0f1cf447d04c1553a",
    "subnet-0b0fd30e11ac920ab"
  ]
}

variable "ec2_key_name" {
  type        = string
  description = "Key name to give the EC2 instances"
  default     = "vockey"
}
