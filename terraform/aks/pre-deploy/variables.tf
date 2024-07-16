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

variable tfstate_prefix {
  type        = string
  default     = "tfstate"
  description = "Terraform remote state file Storage Account prefix name"
}

variable "default_tags" {
  default     = {
    created_by = "Terraform"
    environment = "management"
    }
  description = "Default resource tags"
  type        = map(string)
}