terraform {
  required_version = ">= 1.5"
}

variable "app_name" {
  description = "Name of the app this stack belongs to"
  type        = string
  default     = "e2e-app"
}

# terraform_data is built in, so validate needs no provider download or credentials.
resource "terraform_data" "release" {
  input = {
    app = var.app_name
  }
}

output "app_name" {
  description = "App name recorded by the stack"
  value       = terraform_data.release.output.app
}
