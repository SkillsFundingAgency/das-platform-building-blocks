terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "datastoreName" {
  type = string
}

variable "blobContainerName" {
  type = string
}

variable "storageAccountName" {
  type = string
}

variable "workspaceName" {
  type = string
}

locals { resource_name_parts = split("/", join("", [var.workspaceName, "/", var.datastoreName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.MachineLearningServices/workspaces/datastores@2021-03-01-preview"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.MachineLearningServices", "workspaces", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "contents" = { "contentsType" = "AzureBlob", "accountName" = var.storageAccountName, "containerName" = var.blobContainerName, "endpoint" = "core.windows.net", "protocol" = "https", "credentials" = { "credentialsType" = "None" } }, "properties" = { "ServiceDataAccessAuthIdentity" = "WorkspaceSystemAssignedIdentity" } } }
}
