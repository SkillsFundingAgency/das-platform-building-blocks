terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "appServicePlanName" {
  type = string
}

variable "aspLocation" {
  type    = string
  default = "West Europe"
  validation {
    condition     = (contains(["North Europe", "West Europe", "UK South"], var.aspLocation))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "aseHostingEnvironmentName" {
  type    = string
  default = ""
}

variable "aseResourceGroup" {
  type    = string
  default = ""
}

variable "aspSize" {
  type = string
  validation {
    condition     = (contains(["0", "1", "2", "3"], var.aspSize))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "aspInstances" {
  type = number
}

variable "nonASETier" {
  type    = string
  default = "Standard"
  validation {
    condition     = (contains(["Free", "Basic", "Standard", "Premium", "PremiumV2", "PremiumV3", "Premium0V3"], var.nonASETier))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

locals {
  deployToASE               = (length(var.aseHostingEnvironmentName) > 0)
  aspResourceProperties     = { "WithASE" = { "name" = var.appServicePlanName, "hostingEnvironmentProfile" = { "id" = join("", ["/subscriptions/", data.azurerm_subscription.current.subscription_id, "/resourceGroups/", var.aseResourceGroup, "/providers/Microsoft.Web/hostingEnvironments/", var.aseHostingEnvironmentName]) } }, "WithoutASE" = { "name" = var.appServicePlanName } }
  aspSkuName                = join("", [substr(var.nonASETier, 0, 1), var.aspSize, jsondecode((var.nonASETier == "PremiumV2") ? jsonencode("v2") : jsonencode("")), jsondecode(((var.nonASETier == "PremiumV3") || (var.nonASETier == "Premium0V3")) ? jsonencode("v3") : jsonencode(""))])
  defaultAppServicePlanSKUs = { "NonASE" = { "name" = local.aspSkuName, "tier" = var.nonASETier, "size" = local.aspSkuName, "family" = substr(var.nonASETier, 0, 1), "capacity" = var.aspInstances }, "Isolated" = { "name" = join("", ["I", var.aspSize]), "tier" = "Isolated", "size" = join("", ["I", var.aspSize]), "family" = "I", "capacity" = var.aspInstances } }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Web/serverfarms@2016-09-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.appServicePlanName
  location  = var.aspLocation
  body      = { "properties" = jsondecode(local.deployToASE ? jsonencode(local.aspResourceProperties.WithASE) : jsonencode(local.aspResourceProperties.WithoutASE)), "sku" = jsondecode(local.deployToASE ? jsonencode(local.defaultAppServicePlanSKUs.Isolated) : jsonencode(local.defaultAppServicePlanSKUs.NonASE)) }
}

output "appServicePlanId" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Web", "serverfarms", var.appServicePlanName]) }
