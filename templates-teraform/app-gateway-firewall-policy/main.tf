terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "firewallPolicyName" {
  type        = string
  description = "Must be only lowercase alphanumeric characters"
}

variable "disabledRuleGroups" {
  type    = list(any)
  default = []
}

variable "exclusions" {
  type    = list(any)
  default = []
}

variable "fileUploadLimitInMb" {
  type    = number
  default = 100
}

variable "firewallCustomRules" {
  type    = list(any)
  default = []
}

variable "firewallMode" {
  type    = string
  default = "Prevention"
  validation {
    condition     = (contains(["Detection", "Prevention"], var.firewallMode))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "maxRequestBodySizeInKb" {
  type    = number
  default = 128
}

variable "requestBodyCheck" {
  type    = bool
  default = true
}

variable "ruleSetVersion" {
  type    = string
  default = "3.1"
}

variable "state" {
  type    = string
  default = "Enabled"
  validation {
    condition     = (contains(["Enabled", "Disabled"], var.state))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-06-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.firewallPolicyName
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "policySettings" = { "state" = var.state, "mode" = var.firewallMode, "requestBodyCheck" = var.requestBodyCheck, "maxRequestBodySizeInKb" = var.maxRequestBodySizeInKb, "fileUploadLimitInMb" = var.fileUploadLimitInMb }, "customRules" = var.firewallCustomRules, "managedRules" = { "exclusions" = var.exclusions, "managedRuleSets" = [{ "ruleSetType" = "OWASP", "ruleSetVersion" = var.ruleSetVersion, "ruleGroupOverrides" = var.disabledRuleGroups }] } } }
}
