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
  description = "Name of the storage account"
}

variable "policyRules" {
  type        = list(any)
  default     = []
  description = "A list of management policy rules. See https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2019-06-01/storageaccounts/managementpolicies#managementpolicyrule-object for required properties"
}

locals { resource_name_parts = split("/", join("", [var.storageAccountName, "/default"])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Storage", "storageAccounts", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "policy" = { "rules" = var.policyRules } } }
}
