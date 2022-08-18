provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myrg" {

  location = var.location
  name = var.myrg
  
}

resource "azurerm_virtual_network" "myvn" {

  address_space = var.address_space
  location = var.location
  name = var.virtual_network
  resource_group_name = var.myrg
  
}

resource "azurerm_subnet" "mysubnet" {

  name = "mysubnet"
  resource_group_name = var.myrg
  virtual_network_name = azurerm_virtual_network.myvn.name
  address_prefixes = var.address_prefixes
  
}

resource "azurerm_network_security_group" "aznsg" {

  location = var.location
  name = "mynsg"
  resource_group_name = var.myrg

  dynamic "security_rule" {

    for_each = var.security_rule_ports
    content {
          name                       = "inbound-rule-${security_rule.key}"
          priority                   = sum([100, security_rule.key])
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = security_rule.value
          source_address_prefix      = "*"
          destination_address_prefix = "*"
    }

  }
  
}


resource "azurerm_subnet_network_security_group_association" "nsgsubnetassociation" {
  
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.aznsg.id
}

resource "azurerm_public_ip" "mypip" {
  count = var.countnum
  allocation_method = "Static"
  location = var.location
  name = "linux-vm-pip-${count.index}"
  resource_group_name = var.myrg
  sku = "Standard" 
  
}

resource "azurerm_network_interface" "myni" {
  count = var.countnum
  location = var.location
  name = "mynetworkinterface-${count.index}"
  resource_group_name =  var.myrg
  

  ip_configuration {
    name = "myni-ip-${count.index}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.mypip[*].id, count.index)
    subnet_id = azurerm_subnet.mysubnet.id
  }
  
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  
  count = var.countnum
  admin_username = "azureuser"
  location = var.location
  name = "linux-vm-${count.index}"
  size = "Standard_D2s_v3"
  resource_group_name = var.myrg
  network_interface_ids = [element(azurerm_network_interface.myni[*].id, count.index)]  ## If you compare this line with line number 82 then let me tell you that network interface id's can be multiple and therefore they are always access in [].
  source_image_reference {

    offer = "RHEL"
    publisher = "RedHat"
    sku = "7-LVM"
    version = "latest"
    
  } 

   os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }

  admin_ssh_key {

    public_key = file("${path.module}/aksprodsshkey.pub")
    username = "azureuser"
    
  }

   tags                    = {
          "DeploymentId" = "713703" 
           "LaunchId"     = "21565" 
           "LaunchType"   = "ON_DEMAND_LAB"
           "TemplateId"   = "4283"
           "TenantId"     = "none" 
        }
        
  
}