variable "key_name" {
  description = "EC2 Key pair name"
  default = "khaleel-aws-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "image_tag" {
  description = "Docker image tag from ECR"
  type        = string
}

variable "ecr_repo" {
  description = "ECR repository URL"
  type        = string
}
