terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "eventHubNamespaceName" {
  type = string
}

variable "eventHubAuthorizationRuleName" {
  type = string
}

variable "eventHubAuthorizationRuleRights" {
  type    = list(any)
  default = ["Listen"]
}

locals { resource_name_parts = split("/", join("", [var.eventHubNamespaceName, "/", var.eventHubAuthorizationRuleName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.EventHub/namespaces/authorizationRules@2024-01-01"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.EventHub", "namespaces", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = { "rights" = var.eventHubAuthorizationRuleRights } }
}

output "eventHubAuthorizationRuleId" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.EventHub", "namespaces", var.eventHubNamespaceName, "authorizationRules", var.eventHubAuthorizationRuleName]) }
