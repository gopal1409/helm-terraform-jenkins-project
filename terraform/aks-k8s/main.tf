# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_name_prefix}-${var.resource_group_name}"
  location = var.region
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.resource_name_prefix}-${var.aks}"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "${var.vm_size}"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
