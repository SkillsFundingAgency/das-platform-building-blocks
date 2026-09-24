terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "apimName" {
  type = string
}

variable "productResourceName" {
  type = string
}

variable "productDisplayName" {
  type = string
}

variable "productDescription" {
  type = string
}

variable "productSubscriptionRequired" {
  type = bool
}

variable "productSubscriptionsLimit" {
  type    = string
  default = ""
}

variable "productApprovalRequired" {
  type = bool
}

variable "productState" {
  type = string
}

locals {
  productBaseProperties = { "displayName" = var.productDisplayName, "description" = var.productDescription, "subscriptionRequired" = var.productSubscriptionRequired, "approvalRequired" = var.productApprovalRequired, "state" = var.productState }
}

locals { resource_name_parts = split("/", join("", [var.apimName, "/", var.productResourceName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.ApiManagement/service/products@2021-08-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.ApiManagement", "service", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = ((length(var.productSubscriptionsLimit) == 0) ? local.productBaseProperties : merge(local.productBaseProperties, { "subscriptionsLimit" = tonumber(var.productSubscriptionsLimit) })) }
}
