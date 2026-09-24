terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "automationAccountName" {
  type        = string
  description = "Name of the automation account that hosts the runbook."
}

variable "runbookName" {
  type        = string
  description = "Name of the automation runbook."
}

variable "location" {
  type        = string
  default     = null
  description = "Location for the runbook resource."
}

variable "runbookType" {
  type        = string
  default     = ""
  description = "Execution type for the runbook."
  validation {
    condition     = ((contains(["Graph", "GraphPowerShell", "GraphPowerShellWorkflow", "PowerShell", "PowerShell72", "PowerShellWorkflow", "Python", "Python2", "Python3", "Script"], var.runbookType) || var.runbookType == ""))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "description" {
  type        = string
  default     = ""
  description = "Optional description for the runbook."
}

variable "logVerbose" {
  type        = bool
  default     = false
  description = "Enable verbose logging."
}

variable "logProgress" {
  type        = bool
  default     = false
  description = "Enable progress logging."
}

variable "logActivityTrace" {
  type        = number
  default     = 0
  description = "Activity-level tracing (0-3)."
  validation {
    condition     = (var.logActivityTrace >= 0) && (var.logActivityTrace <= 3)
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "publishContentUri" {
  type        = string
  description = "URI to the packaged runbook script (e.g. storage blob SAS)."
}

variable "publishContentVersion" {
  type        = string
  default     = "1.0.0.0"
  description = "Version label for the published runbook content."
}

locals { resource_name_parts = split("/", join("", [var.automationAccountName, "/", var.runbookName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Automation/automationAccounts/runbooks@2024-10-23"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Automation", "automationAccounts", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  location  = jsondecode(var.location == null ? jsonencode(data.azurerm_resource_group.target.location) : jsonencode(var.location))
  body      = { "properties" = { "description" = var.description, "logVerbose" = var.logVerbose, "logProgress" = var.logProgress, "logActivityTrace" = var.logActivityTrace, "runbookType" = var.runbookType, "publishContentLink" = { "uri" = var.publishContentUri, "version" = var.publishContentVersion } } }
}

output "runbookResourceId" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.Automation", "automationAccounts", var.automationAccountName, "runbooks", var.runbookName]) }
