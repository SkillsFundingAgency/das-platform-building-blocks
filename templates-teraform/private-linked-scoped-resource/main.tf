terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "scopedResourceName" {
  type        = string
  description = "Name of the application insights resource"
}

variable "privateLinkScopeName" {
  type        = string
  description = "Name of the Private Link Scope"
}

variable "scopedResourceId" {
  type    = string
  default = ""
}

locals { resource_name_parts = split("/", join("", [var.privateLinkScopeName, "/", var.scopedResourceName, "-connection"])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Insights/privateLinkScopes/scopedResources@2021-09-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Insights", "privateLinkScopes", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "linkedResourceId" = var.scopedResourceId } }
}
