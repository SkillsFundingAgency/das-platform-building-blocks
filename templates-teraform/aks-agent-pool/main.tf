terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "clusterName" {
  type        = string
  description = "The name of an existing AKS cluster."
}

variable "agentPoolName" {
  type        = string
  description = "The name of the agent pool to create or update."
}

variable "agentNodeCount" {
  type        = number
  default     = 3
  description = "The number of nodes for the cluster."
  validation {
    condition     = (var.agentNodeCount >= 1) && (var.agentNodeCount <= 50)
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "agentVMSize" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "The size of the Virtual Machine."
}

variable "subnetName" {
  type        = string
  description = "Subnet name that will contain the aks CLUSTER"
}

variable "virtualNetworkName" {
  type        = string
  description = "Name of an existing VNET that will contain this AKS deployment."
}

variable "virtualNetworkResourceGroup" {
  type        = string
  default     = null
  description = "Name of the existing VNET resource group"
}

variable "kubernetesVersion" {
  type        = string
  description = "The version of Kubernetes."
}

variable "osType" {
  type    = string
  default = "Linux"
  validation {
    condition     = (contains(["Windows", "Linux"], var.osType))
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "nodeLabels" {
  type    = any
  default = {}
}

variable "nodeTaints" {
  type    = list(any)
  default = []
}

variable "maxPods" {
  type        = number
  default     = 30
  description = "The maximum number of pods per node."
  validation {
    condition     = (var.maxPods >= 30) && (var.maxPods <= 250)
    error_message = "Value must meet the ARM parameter constraints."
  }
}

variable "enableNodeAutoScaling" {
  type        = bool
  default     = false
  description = "Bool to enable node pool autoscaling."
}

variable "minNodeAutoScalingCount" {
  type        = number
  default     = -1
  description = "The minimum amount of nodes to autoscale down to."
}

variable "maxNodeAutoScalingCount" {
  type        = number
  default     = -1
  description = "The maximum amount of nodes to autoscale up to."
}

variable "nodeDrainTimeout" {
  type        = number
  default     = 15
  description = "The amount of time (in minutes) to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails."
}

variable "osDiskSizeGB" {
  type        = number
  default     = 0
  description = "Default of 0 will apply the default osDisk size according to the vmSize specified."
}

variable "enableEncryptionAtHost" {
  type    = bool
  default = true
}

locals {
  vnetSubnetId                  = join("/", ["/subscriptions", data.azurerm_subscription.current.subscription_id, "resourceGroups", jsondecode(var.virtualNetworkResourceGroup == null ? jsonencode(data.azurerm_resource_group.target.name) : jsonencode(var.virtualNetworkResourceGroup)), "providers", "Microsoft.Network", "virtualNetworks", var.virtualNetworkName, "subnets", var.subnetName])
  baseProperties                = { "count" = var.agentNodeCount, "vmSize" = var.agentVMSize, "osType" = var.osType, "osDiskSizeGB" = var.osDiskSizeGB, "storageProfile" = "ManagedDisks", "type" = "VirtualMachineScaleSets", "vnetSubnetID" = local.vnetSubnetId, "orchestratorVersion" = var.kubernetesVersion, "nodeLabels" = var.nodeLabels, "nodeTaints" = var.nodeTaints, "maxPods" = var.maxPods, "enableEncryptionAtHost" = var.enableEncryptionAtHost }
  withAutoscalingNodeProperties = { "enableAutoScaling" = true, "minCount" = var.minNodeAutoScalingCount, "maxCount" = var.maxNodeAutoScalingCount, "upgradeSettings" = { "drainTimeoutInMinutes" = var.nodeDrainTimeout } }
  agentPoolsProperties          = jsondecode(var.enableNodeAutoScaling ? jsonencode(merge(local.baseProperties, local.withAutoscalingNodeProperties)) : jsonencode(local.baseProperties))
}

locals { resource_name_parts = split("/", join("", [var.clusterName, "/", var.agentPoolName])) }

check "resource_name_segments" {
  assert {
    condition     = length(local.resource_name_parts) == 2
    error_message = "ARM resource name must contain 2 segments."
  }
}

resource "azapi_resource" "main" {
  type                      = "Microsoft.ContainerService/managedClusters/agentPools@2023-06-01"
  parent_id                 = join("/", [data.azurerm_resource_group.target.id, "providers", "Microsoft.ContainerService", "managedClusters", local.resource_name_parts[0]])
  name                      = local.resource_name_parts[1]
  schema_validation_enabled = false
  location                  = data.azurerm_resource_group.target.location
  body                      = { "properties" = local.agentPoolsProperties }
}
