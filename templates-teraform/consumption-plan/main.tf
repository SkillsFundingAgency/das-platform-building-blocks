terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "consumptionPlanName" {
  type = string
}

variable "consumptionPlanLocation" {
  type    = string
  default = "West Europe"
  validation {
    condition     = (contains(["North Europe", "West Europe"], var.consumptionPlanLocation))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

locals {
  sku        = { "name" = "Y1", "tier" = "Dynamic" }
  properties = { "name" = var.consumptionPlanName }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Web/serverfarms@2016-09-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.consumptionPlanName
  location  = var.consumptionPlanLocation
  body      = { "sku" = local.sku, "properties" = local.properties }
}

output "ConsumptionPlanName" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Web", "serverfarms", var.consumptionPlanName]) }
