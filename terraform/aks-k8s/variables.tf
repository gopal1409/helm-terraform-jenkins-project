variable "region" {
  default = "East US"
}

variable "business_division" {
  type    = string
  default = "capstone"
}

variable "environment" {
  type    = string
  default = "aks"
}

variable "resource_group_name" {
  type    = string
  default = "rg"
}

variable "aks" {
  type = string
  default = "aks"
}

variable "vm_size" {
  type = string
  default = "Standard_D2_v2"
}
