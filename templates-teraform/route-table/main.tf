terraform {
  required_providers {
    azapi   = { source = "Azure/azapi", version = "~> 2.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

data "azurerm_resource_group" "target" { name = var.resource_group_name }

data "azurerm_subscription" "current" {}

variable "resource_group_name" { type = string }

variable "routeTableName" {
  type        = string
  description = "Name of the Route Table"
}

variable "disableBgpRoutePropagation" {
  type        = bool
  description = "Indicates whether BGP route propagation is disabled"
}

variable "routeTableRoutes" {
  type        = list(any)
  default     = []
  description = "Array of routes to be added to route table"
}

resource "azapi_resource" "main" {
  type      = "Microsoft.Network/routeTables@2024-05-01"
  parent_id = data.azurerm_resource_group.target.id
  name      = var.routeTableName
  location  = data.azurerm_resource_group.target.location
  tags      = {}
  body      = { "properties" = { "disableBgpRoutePropagation" = var.disableBgpRoutePropagation, "routes" = var.routeTableRoutes } }
}
