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

variable "tenantId" {
  type    = string
  default = ""
}

variable "aadGroupObjectId" {
  type    = string
  default = ""
}

variable "groupDisplayName" {
  type = string
}

variable "groupDescription" {
  type = string
}

locals {
  isExternal = ((length(var.tenantId) > 0) && (length(var.aadGroupObjectId) > 0))
}

locals { resource_name_parts = split("/", join("", [var.apimName, "/", jsondecode(local.isExternal ? jsonencode(var.aadGroupObjectId) : jsonencode(var.groupDisplayName))])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.ApiManagement/service/groups@2019-12-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.ApiManagement", "service", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "displayName" = var.groupDisplayName, "description" = var.groupDescription, "type" = jsondecode(local.isExternal ? jsonencode("external") : jsonencode("custom")), "externalId" = jsondecode(local.isExternal ? jsonencode(join("", ["aad://", var.tenantId, "/groups/", var.aadGroupObjectId])) : jsonencode(jsondecode("null"))) } }
}
