terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "actionRuleName" {
  type = string
}

variable "actionRuleScopes" {
  type = list(any)
}

variable "actionRuleEffectiveFrom" {
  type    = string
  default = "1900-01-01T00:00:00"
}

variable "actionRuleTimeZone" {
  type    = string
  default = "GMT Standard Time"
}

variable "actionRuleRecurrence" {
  type    = list(any)
  default = []
}

variable "actionRuleConditions" {
  type    = list(any)
  default = []
}

resource "azapi_resource" "main" {
  type      = "Microsoft.AlertsManagement/actionRules@2021-08-08"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.actionRuleName
  location  = "Global"
  body      = { "properties" = { "scopes" = var.actionRuleScopes, "schedule" = { "effectiveFrom" = var.actionRuleEffectiveFrom, "timeZone" = var.actionRuleTimeZone, "recurrences" = var.actionRuleRecurrence }, "conditions" = var.actionRuleConditions, "enabled" = true, "actions" = [{ "actionType" = "RemoveAllActionGroups" }] } }
}
