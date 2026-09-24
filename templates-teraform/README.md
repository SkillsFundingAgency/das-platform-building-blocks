# Terraform building blocks

This directory contains native Terraform modules built with the AzureRM and
AzAPI providers. It is intentionally spelled `templates-teraform` to match
the requested directory name. Each module mirrors an ARM template path and
uses the same parameter names where possible. The existing `templates` ARM
catalog remains in this branch.

`conversion-status.json` is the coverage ledger. Modules listed under
`native` have Terraform resource definitions. Entries under `pending` have
**no Terraform equivalent yet**; the reason is recorded for each file. Do
not treat this branch as a full ARM-to-Terraform migration until `pending` is
empty and the modules have been reviewed against live Azure deployments.

Example use:

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azapi" {}

module "route_table" {
  source                       = "./templates-teraform/route-table"
  resource_group_name          = var.resource_group_name
  routeTableName               = "example-rt"
  disableBgpRoutePropagation   = false
  routeTableRoutes             = []
}
```

Run `terraform init` and `terraform validate` in a module directory before
use. Existing Azure resources need to be imported into Terraform state before
Terraform manages them. The modules currently do not replace the ARM
deployment step in `azure-pipelines-templates`.

`tools/convert_simple.py` regenerates the modules that have a single resource,
supported expressions, and a statically derivable scope. Run `terraform fmt
-recursive templates-teraform` after regeneration. The script rejects ARM
constructs it cannot translate safely, rather than emitting an ARM deployment
wrapper and calling it Terraform-native.
