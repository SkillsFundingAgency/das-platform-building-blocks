terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "armVnetName" {
  type        = string
  description = "The name of the arm vnet"
}

variable "armVnetAddressSpaceCIDR" {
  type        = string
  description = "CIDR for the address space of the ARM Vnet"
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Network/virtualNetworks@2018-11-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.armVnetName
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "addressSpace" = { "addressPrefixes" = [var.armVnetAddressSpaceCIDR] } } }
}
