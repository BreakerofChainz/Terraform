terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Web-App-1" {
  name     = "Web-App-1"
  location = "East US"
}

resource "azurerm_network_security_group" "Web-App-SG-VM" {
  name                = "Web-App-SG-VM"
  location            = azurerm_resource_group.Web-App-1.location
  resource_group_name = azurerm_resource_group.Web-App-1.name
}

resource "azurerm_network_security_group" "Web-App-SG-LB" {
  name                = "Web-App-SG-LB"
  location            = azurerm_resource_group.Web-App-1.location
  resource_group_name = azurerm_resource_group.Web-App-1.name
}


resource "azurerm_virtual_network" "Web-App-VN" {
  name                = "Web-App-VN"
  location            = azurerm_resource_group.Web-App-1.location
  resource_group_name = azurerm_resource_group.Web-App-1.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "WindowsVM-Subnet" {
    resource_group_name = azurerm_resource_group.Web-App-1.name
    name             = "WindowsVM-Subnet"
    virtual_network_name = azurerm_virtual_network.Web-App-VN.name
    address_prefixes = ["10.0.1.0/24"]
  }

  resource "azurerm_subnet" "LinuxVM-Subnet" {
    resource_group_name = azurerm_resource_group.Web-App-1.name
    name             = "LinuxVM-Subnet"
    virtual_network_name = azurerm_virtual_network.Web-App-VN.name
    address_prefixes = ["10.0.2.0/24"]
  }

  resource "azurerm_subnet" "Bastion-Subnet" {
    resource_group_name = azurerm_resource_group.Web-App-1.name
    name             = "AzureBastionSubnet"
    virtual_network_name = azurerm_virtual_network.Web-App-VN.name
    address_prefixes = ["10.0.0.192/26"]
  }

   resource "azurerm_subnet" "LB-Subnet" {
    resource_group_name = azurerm_resource_group.Web-App-1.name
    name             = "LB-Subnet"
    virtual_network_name = azurerm_virtual_network.Web-App-VN.name
    address_prefixes = ["10.0.102.0/24"]
  }

resource "azurerm_public_ip" "Bastion-IP" {
  name                = "Bastion-IP"
  location            = azurerm_resource_group.Web-App-1.location
  resource_group_name = azurerm_resource_group.Web-App-1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "Web-App-1-Bastion" {
  name                = "Web-App-1-Bastion"
  location            = azurerm_resource_group.Web-App-1.location
  resource_group_name = azurerm_resource_group.Web-App-1.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Bastion-Subnet.id
    public_ip_address_id = azurerm_public_ip.Bastion-IP.id
}
}
