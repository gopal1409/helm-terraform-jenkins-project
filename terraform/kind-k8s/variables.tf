variable "region" {
  default = "East US"
}

variable "business_division" {
  type    = string
  default = "capstone"
}

variable "environment" {
  type    = string
  default = "proj"
}

variable "resource_group_name" {
  type    = string
  default = "rg"
}

variable "virtual_network" {
  type = map(any)
  default = {
    vnet = {
      name             = "vnet"
      address_prefixes = ["11.0.0.0/16"]
    }
  }
}

variable "subnet" {
  type = map(any)
  default = {
    subnet = {
      name             = "kind"
      address_prefixes = ["11.0.1.0/24"]
    }
  }
}

variable "nsg" {
  type = map(any)
  default = {
    rule_1 = {
      name     = "http-port"
      priority = "310"
      port     = "80"
      src_addr_pre = "14.102.43.0/24"
    }
    rule_2 = {
      name     = "port-8080"
      priority = "330"
      port     = "8080"
      src_addr_pre = "14.102.43.0/24"
    }
    rule_3 = {
      name     = "ssh-1"
      priority = "340"
      port     = "22"
      src_addr_pre = "14.102.43.0/24"
    }
    rule_4 = {
      name     = "ssh-2"
      priority = "350"
      port     = "22"
      src_addr_pre = "20.232.35.0/24"
    }
  }
}

variable "vm" {
  type = map(any)
  default = {
    "virtualmachine" = {
      name           = "kind"
      size           = "Standard_DS1_v2"
      admin_username = "kislaya"
    }
  }
}

variable "password" {
  type = string
}
