# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_name_prefix}-${var.resource_group_name}"
  location = var.region
}

# Virtual Network with address space
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_name_prefix}-${var.virtual_network.vnet["name"]}"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.virtual_network.vnet["address_prefixes"]

  tags = local.common_tags
}

# Subnet creation 
resource "azurerm_subnet" "subnet" {
  name                 = "${local.resource_name_prefix}-${var.subnet["subnet"].name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet["subnet"].address_prefixes
}

# Network Security Group Creation
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.resource_name_prefix}-${var.subnet["subnet"].name}-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Create network security rule - open port [80,443] for inbound traffic
resource "azurerm_network_security_rule" "nsg_rule" {
  name                       = each.value["name"]
  priority                   = each.value["priority"]
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = each.value["port"]
  source_address_prefix      = each.value["src_addr_pre"]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = "${local.resource_name_prefix}-${var.subnet["subnet"].name}-nsg"

  depends_on = [
    azurerm_network_security_group.nsg
  ]

  for_each = var.nsg
}

# Create a Public IP for VM
resource "azurerm_public_ip" "public_ip_vm" {
  name                = "${local.resource_name_prefix}-public-ip-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  allocation_method   = "Dynamic"
}

# Create a NIC
resource "azurerm_network_interface" "nic" {
  name                = "${local.resource_name_prefix}-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_vm.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}