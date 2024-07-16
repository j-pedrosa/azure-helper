variable "region" {
  type        = string
  default     = "West Europe"
  description = "Management resources region"
}

variable "prefix" {
  type        = string
  default     = "testing"
  description = "Naming Prefix"
}

variable "default_tags" {
  default = {
    created_by  = "Terraform"
    managed_by  = "Terraform"
    environment = "Testing"
  }
  description = "Default resource tags"
  type        = map(string)
}

variable "aks" {
  type = map(any)
  default = {
    k8s_version                   = "1.28.5"
    agents_pool_max_surge_default = "10%"
    agents_pool_max_surge_system  = null
    agents_pool_max_surge_user    = "20%"
    azure_policy_enabled          = true
  }
}