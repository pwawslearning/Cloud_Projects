resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss.id
  enabled             = true
  profile {
    name = "autoscale"
    capacity {
      default = 3
      minimum = 1
      maximum = 5
    }


  }
}