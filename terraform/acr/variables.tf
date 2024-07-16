variable region {
  type        = string
  default     = "westeurope"
  description = "Azure Region"
}

variable acr_rg {
  type        = string
  default     = "acrrepro"
  description = "Resource Group Name"
}

variable acr_name {
  type        = string
  default     = "acrreprojptst1"
  description = "Specifies the name of the Container Registry. Only Alphanumeric characters allowed. Changing this forces a new resource to be created."
}

variable acr_sku {
  type        = string
  default     = "Premium"
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium."
}

variable acr_admin_enabled {
  type        = bool
  default     = false
  description = "Specifies whether the admin user is enabled. Defaults to false."
}
