resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.location
}
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.address_space]
}
resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets[0]]
}
resource "azurerm_network_security_group" "nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
  }
  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "443"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_associate" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_public_ip" "pip" {
  name                = "lb-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  domain_name_label   = azurerm_resource_group.rg.name
}
resource "azurerm_lb" "lb" {
  name                = "myLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "myPublicaddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
resource "azurerm_lb_backend_address_pool" "BackEndAddressPool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "myBackendpool"
}
resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}
resource "azurerm_lb_rule" "LBRulecheck" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "myLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "myPublicaddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.BackEndAddressPool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}
resource "azurerm_lb_nat_rule" "lbnatRule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "ssh-access"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "myPublicaddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.BackEndAddressPool.id
}
resource "azurerm_public_ip" "natgwpip" {
  name                = "natgw-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "natgw" {
  name                    = "nat-gateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}
resource "azurerm_nat_gateway_public_ip_association" "natgwassoip" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgwpip.id
}
resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.subnet01.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}