terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "customHostname" {
  type = string
}

variable "appServiceName" {
  type = string
}

variable "certificateThumbprint" {
  type = string
}

variable "sslState" {
  type    = string
  default = "SniEnabled"
}

locals { resource_name_parts = split("/", join("", [var.appServiceName, "/", var.customHostname])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Web/sites/hostnameBindings@2022-09-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Web", "sites", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "sslState" = var.sslState, "thumbprint" = var.certificateThumbprint } }
}
