terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "premiumPlanName" {
  type = string
}

variable "maximumElasticWorkerCount" {
  type    = string
  default = "20"
}

variable "premiumPlanLocation" {
  type    = string
  default = "West Europe"
  validation {
    condition     = (contains(["North Europe", "West Europe"], var.premiumPlanLocation))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "skuName" {
  type    = string
  default = "EP1"
  validation {
    condition     = (contains(["EP1", "EP2", "EP3"], var.skuName))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Web/serverfarms@2020-06-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.premiumPlanName
  location  = var.premiumPlanLocation
  body      = { "sku" = { "name" = var.skuName, "tier" = "ElasticPremium" }, "properties" = { "maximumElasticWorkerCount" = var.maximumElasticWorkerCount } }
}

output "PremiumPlanName" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Web", "serverfarms", var.premiumPlanName]) }
