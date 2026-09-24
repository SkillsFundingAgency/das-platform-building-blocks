terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "afdProfileName" {
  type        = string
  description = "Name of the Azure Front Door profile"
}

variable "afdSKU" {
  type        = string
  default     = "Standard_AzureFrontDoor"
  description = "The pricing tier of the Azure Front Door profile."
  validation {
    condition     = (contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.afdSKU))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Cdn/profiles@2023-05-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.afdProfileName
  location  = "global"
  tags      = {}
  body      = { "sku" = { "name" = var.afdSKU } }
}

output "cdnProfileId" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Cdn", "profiles", var.afdProfileName]) }
