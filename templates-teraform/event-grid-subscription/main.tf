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
  description = "Name of the existing Event Grid custom topic to subscribe to. The topic must already exist in the resource group this template is deployed into."
}

variable "eventSubscriptionName" {
  type        = string
  description = "Name of the event subscription to create on the topic."
}

variable "functionAppName" {
  type        = string
  description = "Name of the Function App that hosts the event handler."
}

variable "functionName" {
  type        = string
  description = "Name of the function (within the Function App) that handles the events. The function must be deployed before this subscription is created."
}

variable "functionResourceGroup" {
  type        = string
  description = "Resource group containing the Function App."
}

variable "functionSubscriptionId" {
  type        = string
  default     = data.azurerm_subscription.current.subscription_id
  description = "Subscription ID containing the Function App. Defaults to the current subscription."
}

variable "includedEventTypes" {
  type        = list(any)
  description = "Event types this subscription listens for (for example [\"Microsoft.Security.MalwareScanningResult\"])."
}

variable "maxEventsPerBatch" {
  type        = number
  default     = 1
  description = "Maximum number of events to deliver per batch to the Azure Function."
}

variable "preferredBatchSizeInKilobytes" {
  type        = number
  default     = 64
  description = "Preferred batch size in kilobytes."
}

variable "maxDeliveryAttempts" {
  type        = number
  default     = 30
  description = "Maximum number of delivery retry attempts before an event is dead-lettered or dropped."
}

variable "eventTimeToLiveInMinutes" {
  type        = number
  default     = 1440
  description = "Time-to-live for events in minutes before they are dropped or dead-lettered."
}

variable "eventDeliverySchema" {
  type        = string
  default     = "EventGridSchema"
  description = "Delivery schema for events. Must match what the handler expects (EventGridTrigger functions expect EventGridSchema)."
}

variable "enableDeadLettering" {
  type        = bool
  default     = false
  description = "Whether to enable dead-lettering of undelivered events to a storage blob container."
}

variable "deadLetterStorageAccountResourceId" {
  type        = string
  default     = ""
  description = "Resource ID of the storage account used for dead-lettering. Required when enableDeadLettering is true."
}

variable "deadLetterContainerName" {
  type        = string
  default     = "eventgrid-deadletter"
  description = "Name of the blob container used for dead-lettered events."
}

locals {
  subscriptionPropertiesBase           = { "destination" = { "endpointType" = "AzureFunction", "properties" = { "resourceId" = join("/", ["/subscriptions", var.functionSubscriptionId, "resourceGroups", var.functionResourceGroup, "providers", "Microsoft.Web", "sites", var.functionAppName, "functions", var.functionName]), "maxEventsPerBatch" = var.maxEventsPerBatch, "preferredBatchSizeInKilobytes" = var.preferredBatchSizeInKilobytes } }, "filter" = { "includedEventTypes" = var.includedEventTypes }, "eventDeliverySchema" = var.eventDeliverySchema, "retryPolicy" = { "maxDeliveryAttempts" = var.maxDeliveryAttempts, "eventTimeToLiveInMinutes" = var.eventTimeToLiveInMinutes } }
  deadLetterDestination                = { "endpointType" = "StorageBlob", "properties" = { "resourceId" = var.deadLetterStorageAccountResourceId, "blobContainerName" = var.deadLetterContainerName } }
  subscriptionPropertiesWithDeadLetter = merge(local.subscriptionPropertiesBase, { "deadLetterDestination" = local.deadLetterDestination })
}

locals { resource_name_parts = split("/", join("", [var.topicName, "/", var.eventSubscriptionName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type      = "Microsoft.EventGrid/topics/eventSubscriptions@2022-06-15"
  parent_id = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.EventGrid", "topics", local.resource_name_parts[0]])
  name      = local.resource_name_parts[1]
  body      = { "properties" = (var.enableDeadLettering ? local.subscriptionPropertiesWithDeadLetter : local.subscriptionPropertiesBase) }
}

output "eventSubscriptionName" { value = var.eventSubscriptionName }
