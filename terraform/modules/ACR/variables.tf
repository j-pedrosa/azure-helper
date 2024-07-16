variable "create_acr" {
  type        = bool
  default     = true
  description = "Create or not the ACR (Detault: TRUE)"
}

variable "attach_acr" {
  type        = bool
  default     = true
  description = "Attach or not the ACR to AKS cluster by adding the needed Pull role (Detault: TRUE)"
}
