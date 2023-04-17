# Create a linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.resource_name_prefix}-${var.vm["virtualmachine"].name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  size                = var.vm["virtualmachine"].size 
  admin_username      = var.vm["virtualmachine"].admin_username
  computer_name                   = "${local.resource_name_prefix}-${var.vm["virtualmachine"].name}"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = false
  admin_password                  = var.password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
