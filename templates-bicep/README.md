# Bicep building blocks

The directory mirrors the 102 ARM templates under `../templates`, including
their subdirectories. File names, parameter names, defaults, resource API
versions, and outputs are retained where Bicep can express them. The existing
root-level `apim-policy-fragment.bicep` is retained for compatibility; the
ARM-aligned version is `apim/apim-policy-fragment.bicep`.

Two files are **ARM-backed compatibility modules**:

- `app-gateway-v2.bicep`: the Bicep decompiler fails on the ARM template's
  variable copy loops. This module passes the same parameters to the original
  local ARM template.
- `diagnostic-settings.bicep`: the ARM template accepts an arbitrary resource
  ID as its extension-resource scope. Bicep requires a statically typed
  resource symbol for that scope. This module passes the same parameters and
  exposes the same outputs.

These two compile and deploy through Bicep, but their resource definitions
still reside in the ARM JSON. They require a design change to become native
Bicep without narrowing the existing parameter contract.

Compile any block with `az bicep build --file templates-bicep/<name>.bicep`.
All 102 ARM-aligned Bicep files compile with Bicep CLI 0.46.1. Compilation
checks syntax and local module references; it does not deploy resources.
