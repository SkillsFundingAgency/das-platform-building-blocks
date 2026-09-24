terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "appInsightsName" {
  type        = string
  description = "The name of the application insights instance"
}

variable "appInsightsResourceGroup" {
  type        = string
  default     = data.azurerm_resource_group.target.name
  description = "The resource group that contains the application insights instance"
}

variable "actionGroupResourceId" {
  type        = string
  description = "The resource id of the action group to associate with this alert"
}

variable "severity" {
  type        = string
  default     = "Sev2"
  description = "The severity of the alert"
}

resource "azapi_resource" "main" {
  type      = "microsoft.alertsmanagement/smartdetectoralertrules@2019-03-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = join("", ["Failure Anomalies - ", var.appInsightsName])
  location  = "global"
  body      = { "properties" = { "description" = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.", "state" = "Enabled", "severity" = var.severity, "frequency" = "PT1M", "detector" = { "id" = "FailureAnomaliesDetector" }, "scope" = [join("/", ["/subscriptions", data.azurerm_subscription.current.subscription_id, "resourceGroups", var.appInsightsResourceGroup, "providers", "Microsoft.Insights", "components", var.appInsightsName])], "actionGroups" = { "groupIds" = [var.actionGroupResourceId] } } }
}
