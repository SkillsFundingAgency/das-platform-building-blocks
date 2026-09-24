terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "enabled" {
  type    = bool
  default = true
}

variable "serviceName" {
  type        = string
  description = "The web app name that the alert is applied for"
}

variable "applicationInsightsResourceId" {
  type        = string
  description = "The application insights resource ID that the alert is applied on"
}

variable "alertActionGroupResourceId" {
  type        = string
  description = "The id of the action group to send the alert to."
}

variable "alertSeverity" {
  type        = number
  default     = 1
  description = "Severity of alert {0,1,2,3,4}"
  validation {
    condition     = (contains([0, 1, 2, 3, 4], var.alertSeverity))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "windowSize" {
  type        = string
  default     = "PT30M"
  description = "Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day. ISO 8601 duration format."
  validation {
    condition     = (contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H", "P1D"], var.windowSize))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "evaluationFrequency" {
  type        = string
  default     = "PT1M"
  description = "How often the metric alert is evaluated. ISO 8601 duration format."
  validation {
    condition     = (contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H"], var.evaluationFrequency))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "dimensions" {
  type        = list(any)
  default     = null
  description = "An array of metric dimensions used to filter the metric being alerted on"
}

variable "alertSensitivity" {
  type        = string
  default     = "Medium"
  description = "The Dynamic threshold sensitivity"
}

variable "numberOfEvaluationPeriods" {
  type    = number
  default = 1
}

variable "minFailingPeriodsToAlert" {
  type    = number
  default = 1
}

locals {
  alertName = join("", [var.serviceName, " Response Time Alert"])
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Insights/metricAlerts@2018-03-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = local.alertName
  location  = "global"
  tags      = {}
  body      = { "properties" = { "severity" = var.alertSeverity, "enabled" = var.enabled, "scopes" = [var.applicationInsightsResourceId], "evaluationFrequency" = var.evaluationFrequency, "windowSize" = var.windowSize, "criteria" = { "allOf" = [{ "alertSensitivity" = var.alertSensitivity, "failingPeriods" = { "numberOfEvaluationPeriods" = var.numberOfEvaluationPeriods, "minFailingPeriodsToAlert" = var.minFailingPeriodsToAlert }, "name" = "responseTime", "metricNamespace" = "microsoft.insights/components", "metricName" = "requests/duration", "dimensions" = jsondecode(var.dimensions == null ? jsonencode([{ "name" = "cloud/roleName", "operator" = "Include", "values" = [var.serviceName] }]) : jsonencode(var.dimensions)), "operator" = "GreaterThan", "timeAggregation" = "Maximum", "skipMetricValidation" = false, "criterionType" = "DynamicThresholdCriterion" }], "odata.type" = "Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria" }, "autoMitigate" = true, "targetResourceType" = "microsoft.insights/components", "targetResourceRegion" = "westeurope", "actions" = [{ "actionGroupId" = var.alertActionGroupResourceId, "webHookProperties" = {} }] } }
}
