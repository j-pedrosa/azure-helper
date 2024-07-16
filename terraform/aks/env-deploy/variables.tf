variable region {
  type        = string
  default     = "West Europe"
  description = "Management resources region"
}

variable rg_prefix {
  type        = string
  default     = "rg-management"
  description = "Management Resource Group prefix"
}

variable "default_tags" {
  default     = {
    created_by = "Terraform"
    managed_by = "Terraform"
    environment = "Testing"
    }
  description = "Default resource tags"
  type        = map(string)
}