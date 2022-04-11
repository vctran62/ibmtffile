provider "azurerm" {
  features {}
}

##### Create Resource Group #####
resource "azurerm_resource_group" "rg-tools" {
  name     = "rg-sc-cdw-vpt-dev-tools-01"
  location = "South Central US"
}


##### Networking Start #####
resource "azurerm_network_security_group" "nsg-tools-01" {
  name                = "nsg-snet-sc-cdw-vpt-dev-tools-01"
  location            = azurerm_resource_group.rg-tools.location
  resource_group_name = azurerm_resource_group.rg-tools.name
}

resource "azurerm_virtual_network" "vnet-tools-01" {
  name                = "vnet-sc-cdw-vpt-dev-tools-01"
  address_space       = ["10.104.0.0/16"]
  location            = azurerm_resource_group.rg-tools.location
  resource_group_name = azurerm_resource_group.rg-tools.name
  dns_servers = [ "10.255.1.4",
                  "10.255.1.5", ]
}

resource "azurerm_subnet" "snet-tools-01" {
  name                 = "snet-sc-cdw-vpt-dev-tools-01"
  virtual_network_name = azurerm_virtual_network.vnet-tools-01.name
  resource_group_name  = azurerm_virtual_network.vnet-tools-01.resource_group_name
  address_prefixes     = ["10.104.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "assoc-tools-01" {
  subnet_id                 = azurerm_subnet.snet-tools-01.id
  network_security_group_id = azurerm_network_security_group.nsg-tools-01.id
}
##### Networking End #####

##### Linux VM Start #####
resource "azurerm_network_interface" "nic-01-sc-vpttools01" {
  name                = "nic-01-sc-vpttools01"
  location            = "South Central US"
  resource_group_name = "rg-sc-cdw-vpt-dev-tools-01"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/a986816a-9bbc-44b7-ba43-d72505ca9c0c/resourceGroups/rg-sc-cdw-vpt-dev-tools-01/providers/Microsoft.Network/virtualNetworks/vnet-sc-cdw-vpt-dev-tools-01/subnets/snet-sc-cdw-vpt-dev-tools-01"
    private_ip_address_allocation = "Dynamic"
     
  }
}

resource "azurerm_linux_virtual_machine" "vm-sc-vpttools01" {
  name                            = "sc-vpttools01"
  resource_group_name             = azurerm_network_interface.nic-01-sc-vpttools01.resource_group_name
  location                        = azurerm_network_interface.nic-01-sc-vpttools01.location
  size                            = "Standard_B2s"
  admin_username                  = "vmadmin"
  admin_password                  = " "
  disable_password_authentication = "false"
  tags                            = {
                                      Backup ="Daily"
                                    }
  network_interface_ids = [
   azurerm_network_interface.nic-01-sc-vpttools01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "rhel-byos"
    sku       = "rhel-lvm83"
    version   = "latest"
  }

  plan {
    name      = "rhel-lvm83"
    publisher = "redhat"
    product   = "rhel-byos"
  }
}

resource "azurerm_network_interface" "nic-01-sc-vptilmt01" {
  name                = "nic-01-sc-vptilmt01"
  location            = "South Central US"
  resource_group_name = "rg-sc-cdw-vpt-dev-tools-ilmt-01"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/a986816a-9bbc-44b7-ba43-d72505ca9c0c/resourceGroups/rg-sc-cdw-vpt-dev-tools-01/providers/Microsoft.Network/virtualNetworks/vnet-sc-cdw-vpt-dev-tools-01/subnets/snet-sc-cdw-vpt-dev-tools-01"
    private_ip_address_allocation = "Dynamic"
     
  }
}

resource "azurerm_linux_virtual_machine" "vm-sc-vptilmt01" {
  name                            = "sc-d-vptilmt01"
  resource_group_name             = azurerm_network_interface.nic-01-sc-vptilmt01.resource_group_name
  location                        = azurerm_network_interface.nic-01-sc-vptilmt01.location
  size                            = "Standard_D4ds_v4"
  admin_username                  = "vmadmin"
  admin_password                  = " "
  disable_password_authentication = "false"
  tags                            = {
                                      Backup ="Daily"
                                    }
  network_interface_ids = [
   azurerm_network_interface.nic-01-sc-vptilmt01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "rhel-byos"
    sku       = "rhel-lvm83"
    version   = "latest"
  }

  plan {
    name      = "rhel-lvm83"
    publisher = "redhat"
    product   = "rhel-byos"
  }
}

resource "azurerm_managed_disk" "md-01-sc-d-vptilmt01" {
  name                 = "md-01-sc-d-vptilmt01"
  location             = "South Central US"
  resource_group_name  = "rg-sc-cdw-vpt-dev-tools-ilmt-01"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "vptilmt01-attach" {
  managed_disk_id    = azurerm_managed_disk.md-01-sc-d-vptilmt01.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-sc-vptilmt01.id
  lun                = "1"
  caching            = "ReadWrite"
}
##### Linux VM End #####

##### Windows VM Start #####
resource "azurerm_network_interface" "nic-01-sc-vpttools02" {
  name                = "nic-01-sc-vpttools02"
  location            = "South Central US"
  resource_group_name = "rg-sc-cdw-vpt-dev-tools-01"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/a986816a-9bbc-44b7-ba43-d72505ca9c0c/resourceGroups/rg-sc-cdw-vpt-dev-tools-01/providers/Microsoft.Network/virtualNetworks/vnet-sc-cdw-vpt-dev-tools-01/subnets/snet-sc-cdw-vpt-dev-tools-01"
    private_ip_address_allocation = "Dynamic"
     
  }
}

resource "azurerm_windows_virtual_machine" "vm-sc-vpttools02" {
  name                            = "sc-vpttools02"
  resource_group_name             = azurerm_network_interface.nic-01-sc-vpttools02.resource_group_name
  location                        = azurerm_network_interface.nic-01-sc-vpttools02.location
  size                            = "Standard_B2s"
  admin_username                  = "vmadmin"
  admin_password                  = " "
  tags                            = {
                                      Backup ="Daily"
                                    }
  network_interface_ids = [
    azurerm_network_interface.nic-01-sc-vpttools02.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}
##### Windows VM End #####

##### Bastion Start #####
# resource "azurerm_subnet" "snet-toosl-02" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.rg-tools.name
#   virtual_network_name = azurerm_virtual_network.vnet-tools-01.name
#   address_prefixes     = ["10.104.200.0/27"]
# }

# resource "azurerm_public_ip" "bast-pip-tools-01" {
#   name                = "bast-pip-vnet-sc-cdw-vpt-dev-tools-01"
#   location            = azurerm_resource_group.rg-tools.location
#   resource_group_name = azurerm_resource_group.rg-tools.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_bastion_host" "bast-tools" {
#   name                = "bast-vnet-sc-cdw-vpt-dev-tools-01"
#   location            = azurerm_resource_group.rg-tools.location
#   resource_group_name = azurerm_resource_group.rg-tools.name

#   ip_configuration {
#     name                 = "bast-cfg-sc-cdw-vpt-dev-tools-01"
#     subnet_id            = azurerm_subnet.snet-toosl-02.id
#     public_ip_address_id = azurerm_public_ip.bast-pip-tools-01.id
#   }
# }

##### Bastion End #####
