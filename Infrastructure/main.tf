data "azurerm_virtual_network" "example" {
  name                = "project-network"
  resource_group_name = "project-network-rg"
}

data "azurerm_ssh_public_key" "example" {
  name                = "testwp-vm_key"
  resource_group_name = "ami-group"
}


# Reference an existing VNet subnet
data "azurerm_subnet" "example" {
  name                 = "app-subnet-1"
  virtual_network_name = "project-network"
  resource_group_name  = "project-network-rg"
}

# Create a Public IP for the Load Balancer
resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "rjwp"
}

# Create the Load Balancer
resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_probe" "example" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.example.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}


# Backend Address Pool for the Load Balancer
resource "azurerm_lb_backend_address_pool" "example" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.example.id
}


resource "azurerm_lb_rule" "example" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "primary"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "allow_http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = data.azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "example-vmss"
  resource_group_name = var.rg
  location            = var.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "adminuser"
  source_image_id     = var.ami

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.example.public_key
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = data.azurerm_subnet.example.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]
    }
  }
}

resource "azurerm_cdn_profile" "example" {
  name                = "wp-cdn-profile"
  location            = var.location
  resource_group_name = var.rg

  sku = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "example" {
  name                = "wp-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.example.name
  location            = var.location
  resource_group_name = var.rg

  origin {
    name      = "example-origin"
    host_name = azurerm_public_ip.example.fqdn # replace with your LB public IP DNS name
    http_port = 80
  }

  depends_on = [azurerm_public_ip.example]

  # Additional settings like query string caching, compression can be added
}

resource "azurerm_cdn_endpoint_custom_domain" "example" {
  name            = "wp-custom-domain"
  host_name       = "rjwp.azure.vsystems.online"
  cdn_endpoint_id = azurerm_cdn_endpoint.example.id
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
  }
}
