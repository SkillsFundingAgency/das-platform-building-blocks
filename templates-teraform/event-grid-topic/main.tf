terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "topicName" {
  type        = string
  description = "Name of the Event Grid custom topic to create."
}

variable "location" {
  type        = string
  default     = null
  description = "Location of the topic. For Defender malware scan results this must match the region of the storage account whose results it receives."
}

variable "inputSchema" {
  type        = string
  default     = "EventGridSchema"
  description = "Schema in which events are published to the topic."
  validation {
    condition     = (contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.inputSchema))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "publicNetworkAccess" {
  type        = string
  default     = "Enabled"
  description = "Whether the topic accepts traffic from public IPs. Defender for Storage cannot publish to a topic that only allows private endpoints, so this must be Enabled for malware scan results."
  validation {
    condition     = (contains(["Enabled", "Disabled"], var.publicNetworkAccess))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.EventGrid/topics@2022-06-15"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.topicName
  location  = jsondecode(var.location == null ? jsonencode(data.azurerm_resource_group.target.location) : jsonencode(var.location))
  body      = { "properties" = { "inputSchema" = var.inputSchema, "publicNetworkAccess" = var.publicNetworkAccess } }
}

output "topicName" { value = var.topicName }

output "topicResourceId" { value = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.EventGrid", "topics", var.topicName]) }
