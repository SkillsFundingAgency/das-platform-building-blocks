terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "sqlServerName" {
  type = string
}

variable "elasticPoolName" {
  type = string
}

variable "elasticPoolEdition" {
  type    = string
  default = "Standard"
  validation {
    condition     = (contains(["Basic", "Standard", "Premium"], var.elasticPoolEdition))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "elasticPoolDtu" {
  type    = number
  default = 50
}

variable "elasticPoolMinDtu" {
  type    = number
  default = 0
}

variable "elasticPoolMaxDtu" {
  type    = number
  default = 20
}

locals { resource_name_parts = split("/", join("", [var.sqlServerName, "/", var.elasticPoolName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Sql/servers/elasticpools@2014-04-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Sql", "servers", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "edition" = var.elasticPoolEdition, "dtu" = var.elasticPoolDtu, "databaseDtuMin" = var.elasticPoolMinDtu, "databaseDtuMax" = var.elasticPoolMaxDtu } }
}
