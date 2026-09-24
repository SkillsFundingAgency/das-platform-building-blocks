terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "failoverGroupName" {
  type = string
}

variable "primarySqlServerName" {
  type = string
}

variable "secondarySqlServerName" {
  type = string
}

variable "databases" {
  type        = list(any)
  description = "String array of database resource IDs"
}

variable "failoverPolicy" {
  type    = string
  default = "Manual"
  validation {
    condition     = (contains(["Manual"], var.failoverPolicy))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

locals { resource_name_parts = split("/", lower(join("", [var.primarySqlServerName, "/", var.failoverGroupName]))) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Sql/servers/failoverGroups@2015-05-01-preview"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Sql", "servers", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "readWriteEndpoint" = { "failoverPolicy" = var.failoverPolicy }, "partnerServers" = [{ "id" = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Sql", "servers", var.secondarySqlServerName]) }], "databases" = var.databases } }
}
