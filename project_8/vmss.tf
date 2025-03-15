
resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
  name                = "myVMSS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.sku_name[0]
  instances           = 3

  platform_fault_domain_count = 1
  user_data_base64            = base64encode(file("user_data.sh"))
  zones                       = ["1"]
  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = "azureuser"
      admin_ssh_key {
        username   = "azureuser"
        public_key = file(".ssh/id_rsa.pub")
      }
    }
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }
  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false
    ip_configuration {
      name                                   = "myIPconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet01.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.BackEndAddressPool.id]
    }
  }
}