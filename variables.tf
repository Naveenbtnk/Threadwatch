variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "alert_email" {
  description = "Email address for security alerts (required - set in terraform.tfvars)"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
}