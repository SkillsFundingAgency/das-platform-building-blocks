terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "alertName" {
  type        = string
  description = "Name of metric alert."
}

variable "alertDescription" {
  type        = string
  default     = ""
  description = "Description of metric alert."
}

variable "alertSeverity" {
  type        = number
  default     = 3
  description = "Severity of alert {0,1,2,3,4}"
  validation {
    condition     = (contains([0, 1, 2, 3, 4], var.alertSeverity))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "isEnabled" {
  type        = bool
  default     = true
  description = "Specifies whether the alert is enabled."
}

variable "targetResourceType" {
  type        = string
  default     = "microsoft.insights/components"
  description = "Type of target resource."
  validation {
    condition     = (contains(["microsoft.insights/components", "Microsoft.DataFactory/factories", "Microsoft.Network/applicationGateways"], var.targetResourceType))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "resourceIdScopeList" {
  type        = list(any)
  description = "The list of resource id's that this metric alert is scoped to, e.g. list of Application Insights resources."
}

variable "metricNamepace" {
  type        = string
  default     = "microsoft.insights/components"
  description = "Namespace of the metric."
  validation {
    condition     = (contains(["microsoft.insights/components", "Microsoft.DataFactory/factories", "Microsoft.Network/applicationGateways"], var.metricNamepace))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "metricName" {
  type        = string
  description = "Name of the metric, dependent on the metric namespace. E.g. 'dependencies/failed' for 'microsoft.insights/components' namespace."
}

variable "metricOperator" {
  type        = string
  default     = "GreaterThan"
  description = "Operator comparing the current value with the threshold value."
  validation {
    condition     = (contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], var.metricOperator))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "metricThreshold" {
  type        = number
  description = "The threshold value that activates the alert."
}

variable "timeAggregation" {
  type        = string
  default     = "Count"
  description = "How the data that is collected should be combined over time."
  validation {
    condition     = (contains(["Average", "Minimum", "Maximum", "Total", "Count"], var.timeAggregation))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "windowSize" {
  type        = string
  default     = "PT5M"
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

variable "actionGroupResourceId" {
  type        = string
  description = "The id of the action group to send the alert to."
}

variable "dimensions" {
  type        = list(any)
  default     = []
  description = "An optional array of metric dimensions used to filter the metric being alerted on"
}

resource "azapi_resource" "main" {
  type      = "microsoft.insights/metricAlerts@2018-03-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.alertName
  location  = "global"
  tags      = {}
  body      = { "properties" = { "description" = var.alertDescription, "severity" = var.alertSeverity, "enabled" = var.isEnabled, "scopes" = var.resourceIdScopeList, "evaluationFrequency" = var.evaluationFrequency, "windowSize" = var.windowSize, "criteria" = { "odata.type" = "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria", "allOf" = [{ "threshold" = var.metricThreshold, "name" = "Metric1", "metricNamespace" = var.metricNamepace, "metricName" = var.metricName, "dimensions" = var.dimensions, "operator" = var.metricOperator, "timeAggregation" = var.timeAggregation, "criterionType" = "StaticThresholdCriterion" }] }, "autoMitigate" = true, "targetResourceType" = var.targetResourceType, "actions" = [{ "actionGroupId" = var.actionGroupResourceId }] } }
}
