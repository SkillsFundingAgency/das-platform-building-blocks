terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "policyName" {
  type        = string
  description = "The name of the Web Application Firewall Policy"
}

variable "enabledState" {
  type        = string
  default     = "Enabled"
  description = "Describes if the policy is in enabled or disabled state. Defaults to Enabled if not specified. - Disabled or Enabled"
  validation {
    condition     = (contains(["Enabled", "Disabled"], var.enabledState))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "mode" {
  type        = string
  default     = "Prevention"
  description = "Describes if it is in detection mode or prevention mode at policy level. - Prevention or Detection"
  validation {
    condition     = (contains(["Prevention", "Detection"], var.mode))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "ruleSetVersion" {
  type        = string
  default     = "1.0"
  description = "Defines the version of the rule set to use"
}

variable "ruleGroupOverrides" {
  type        = list(any)
  default     = []
  description = "Defines the rule group overrides to apply to the rule set. Pass an array of ManagedRuleGroupOverride objects (https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-03-01/frontdoorwebapplicationfirewallpolicies#managedrulegroupoverride-object)."
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2019-03-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.policyName
  location  = "global"
  body      = { "properties" = { "policySettings" = { "enabledState" = var.enabledState, "mode" = var.mode }, "managedRules" = { "managedRuleSets" = [{ "ruleSetType" = "DefaultRuleSet", "ruleSetVersion" = var.ruleSetVersion, "ruleGroupOverrides" = var.ruleGroupOverrides }] } } }
}
