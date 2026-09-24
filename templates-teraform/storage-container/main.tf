terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "storageAccountName" {
  type        = string
  description = "Name of the storage account the container belongs to"
}

variable "containerName" {
  type        = string
  description = "Name of the container"
}

variable "publicAccess" {
  type        = string
  default     = "None"
  description = "Level of public accessibility of the created container"
  validation {
    condition     = (contains(["Container", "Blob", "None"], var.publicAccess))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

locals { resource_name_parts = split("/", join("", [var.storageAccountName, "/default/", var.containerName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 3
    error_message = "ARM resource name must contain 3 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2019-04-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Storage", "storageAccounts", local.resource_name_parts[0], "blobServices", local.resource_name_parts[1]])
  name      = local.resource_name_parts[2]
  body      = { "properties" = { "publicAccess" = var.publicAccess } }
}
