terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "nsgName" {
  type = string
}

variable "securityRules" {
  type = list(any)
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Network/networkSecurityGroups@2020-04-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.nsgName
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "securityRules" = var.securityRules } }
}
