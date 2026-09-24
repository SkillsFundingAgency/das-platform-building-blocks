terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "cdnProfileName" {
  type        = string
  description = "Name of Content Delivery Network (CDN) profile"
}

variable "cdnSKU" {
  type    = string
  default = "Standard_Verizon"
  validation {
    condition     = (contains(["Premium_Verizon", "Custom_Verizon", "Standard_Verizon", "Standard_Akamai", "Standard_Microsoft"], var.cdnSKU))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Cdn/profiles@2017-10-12"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.cdnProfileName
  location  = data.azurerm_resource_group.target.location
  tags      = {}
  body      = { "sku" = { "name" = var.cdnSKU } }
}
