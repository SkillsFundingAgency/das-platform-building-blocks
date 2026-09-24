terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "actionGroupId" {
  type        = string
  description = "The id of the action group to send the alert to as outputed by action-group.json."
}

variable "alertDescription" {
  type        = string
  description = "A friendly description for the alert."
}

variable "alertFrequency" {
  type        = number
  description = "The frequency that the queryMetricThreshold is assessed."
}

variable "alertMessageSubject" {
  type        = string
  description = "The subject of the alert email (this may also be visible in other action group types)."
}

variable "alertPeriod" {
  type        = number
  description = "The timespan over which to measure the queryMetricThreshold."
}

variable "alertResourceName" {
  type        = string
  description = "The name of the Azure Resource Manager resource that represents the alert."
}

variable "alertTriggerOperator" {
  type        = string
  description = "The operator used to assess the queryMetricThreshold against the query result. Must be one of the metricTrigger thresholdOperator values supported by scheduledQueryRules (Equal, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual)."
  validation {
    condition     = (contains(["Equal", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], var.alertTriggerOperator))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "alertTriggerMetricTriggerType" {
  type        = string
  description = "Whether to trigger the alert based on the total number of breaches or the consecutive number."
  validation {
    condition     = (contains(["Consecutive", "Total"], var.alertTriggerMetricTriggerType))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "alertTriggerThreshold" {
  type        = number
  description = "The threshold for the trigger."
}

variable "kustoQuery" {
  type        = string
  description = "The kusto query used to retrieve the query metric."
}

variable "logAnalyticsId" {
  type        = string
  description = "The id of the log analytics workspace as outputed by log-analtyics-workspace.json."
}

variable "queryMetricThreshold" {
  type        = number
  description = "The threshold used to assess the results of the kusto query."
}

variable "severity" {
  type        = number
  description = "The alert severity, used to group alerts by Azure."
  validation {
    condition     = (var.severity >= 0) && (var.severity <= 4)
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "enableAlert" {
  type    = bool
  default = true
}

variable "queryMetricThresholdOperator" {
  type        = string
  default     = "GreaterThan"
  description = "The operator used to assess the results of the kusto query against the threshold."
  validation {
    condition     = (contains(["Equal", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], var.queryMetricThresholdOperator))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "additionalActionGroupIds" {
  type        = list(any)
  default     = []
  description = "Optional additional action group ids to invoke alongside actionGroupId, for example a group that triggers a remediation Logic App. Kept separate so a shared notification group can still be passed as actionGroupId."
}

variable "autoMitigate" {
  type        = bool
  default     = false
  description = "When true, the alert is automatically resolved once the query stops breaching, sending a resolved notification to the action groups. Defaults to false to preserve the existing fire-only behaviour of alerts that do not opt in."
}

locals {
  alertActionBase = { "odata.type" = "Microsoft.WindowsAzure.Management.Monitoring.Alerts.Models.Microsoft.AppInsights.Nexus.DataContracts.Resources.ScheduledQueryRules.AlertingAction", "severity" = tostring(var.severity), "aznsAction" = { "actionGroup" = join("", [[var.actionGroupId], var.additionalActionGroupIds]), "emailSubject" = var.alertMessageSubject }, "trigger" = { "thresholdOperator" = var.queryMetricThresholdOperator, "threshold" = var.queryMetricThreshold, "metricTrigger" = { "thresholdOperator" = var.alertTriggerOperator, "threshold" = var.alertTriggerThreshold, "metricTriggerType" = var.alertTriggerMetricTriggerType } } }
}

resource "azapi_resource" "main" {
  type      = "microsoft.insights/scheduledQueryRules@2018-04-16"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.alertResourceName
  location  = data.azurerm_resource_group.target.location
  body      = { "properties" = { "description" = var.alertDescription, "enabled" = var.enableAlert, "autoMitigate" = var.autoMitigate, "source" = { "query" = var.kustoQuery, "dataSourceId" = var.logAnalyticsId, "queryType" = "ResultCount" }, "schedule" = { "frequencyInMinutes" = var.alertFrequency, "timeWindowInMinutes" = var.alertPeriod }, "action" = merge(local.alertActionBase, (var.autoMitigate ? jsondecode("{}") : jsondecode("{\"throttlingInMin\": 20}"))) } }
}
