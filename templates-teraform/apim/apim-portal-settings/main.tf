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

variable "enabled" {
  type = bool
}

locals { resource_name_parts = split("/", join("", [var.apimName, "/signup"])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.ApiManagement/service/portalsettings@2020-12-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.ApiManagement", "service", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "enabled" = var.enabled, "termsOfService" = { "consentRequired" = "false", "enabled" = "false", "text" = "" } } }
}
