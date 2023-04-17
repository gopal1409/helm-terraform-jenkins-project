# Null resource using file provisioner to transfer script.sh to the VM and remote-exec to run the script
resource "null_resource" "install_kind" {

  triggers = {
    id = azurerm_linux_virtual_machine.vm.id
  }

    connection {
      type     = "ssh"
      user     = var.vm["virtualmachine"].admin_username
      password = var.password
      host     = azurerm_linux_virtual_machine.vm.public_ip_address
    }

  provisioner "file" {
    source      = "script.sh"
    destination = "/home/kislaya/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/kislaya/script.sh",
      "/home/kislaya/script.sh"
    ]
  }

  provisioner "file" {
    source      = "helm/simple-app"
    destination = "/home/kislaya"
  } 
 
  depends_on = [azurerm_linux_virtual_machine.vm]
}