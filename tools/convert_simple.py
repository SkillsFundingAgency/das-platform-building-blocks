"""Generate native AzAPI modules for ARM templates with one top-level resource.

This deliberately rejects constructs it cannot translate faithfully. It never
modifies the ARM sources. Run from the repository root with Python 3.
"""

import ast
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE = ROOT / "templates"
DEST = ROOT / "templates-teraform"
PARAMETER_NAMES = {}
VARIABLE_NAMES = {}
ARRAY_PARAMETERS = set()
ARRAY_VARIABLES = set()
PARAMETER_DYNAMIC_DEFAULTS = {}


class Unsupported(Exception):
    pass


def quoted(value):
    return json.dumps(value, ensure_ascii=False)


def call(name, args):
    if name == "parameters":
        key = ast.literal_eval(args[0])
        canonical = PARAMETER_NAMES.get(key.casefold(), key)
        if canonical.casefold() in PARAMETER_DYNAMIC_DEFAULTS:
            fallback = emit(PARAMETER_DYNAMIC_DEFAULTS[canonical.casefold()])
            return f"jsondecode(var.{canonical} == null ? jsonencode({fallback}) : jsonencode(var.{canonical}))"
        return f"var.{canonical}"
    if name == "variables":
        key = ast.literal_eval(args[0])
        return f"local.{VARIABLE_NAMES.get(key.casefold(), key)}"
    if name == "resourceGroup":
        return "data.azurerm_resource_group.target"
    if name == "subscription":
        return "data.azurerm_subscription.current"
    if name == "concat":
        def is_array(arg):
            if isinstance(arg, ast.List):
                return True
            if isinstance(arg, ast.Call) and isinstance(arg.func, ast.Name):
                if arg.func.id in ("createArray", "array"):
                    return True
                if arg.func.id == "parameters" and isinstance(arg.args[0], ast.Constant):
                    return arg.args[0].value.casefold() in ARRAY_PARAMETERS
                if arg.func.id == "variables" and isinstance(arg.args[0], ast.Constant):
                    return arg.args[0].value.casefold() in ARRAY_VARIABLES
            return False
        if any(is_array(arg) for arg in args):
            return "concat(" + ", ".join(emit_ast(a) for a in args) + ")"
        return "join(\"\", [" + ", ".join(emit_ast(a) for a in args) + "])"
    if name in ("if", "_if"):
        return f"jsondecode({emit_ast(args[0])} ? jsonencode({emit_ast(args[1])}) : jsonencode({emit_ast(args[2])}))"
    if name == "equals":
        return f"({emit_ast(args[0])} == {emit_ast(args[1])})"
    if name == "greater":
        return f"({emit_ast(args[0])} > {emit_ast(args[1])})"
    if name in ("not", "_not"):
        return f"(!{emit_ast(args[0])})"
    if name in ("and", "_and"):
        return "(" + " && ".join(emit_ast(a) for a in args) + ")"
    if name in ("or", "_or"):
        return "(" + " || ".join(emit_ast(a) for a in args) + ")"
    if name == "empty":
        return f"(length({emit_ast(args[0])}) == 0)"
    if name == "toLower":
        name = "lower"
    if name == "json":
        name = "jsondecode"
    if name == "string":
        name = "tostring"
    if name == "int":
        name = "tonumber"
    if name == "bool":
        name = "tobool"
    if name == "createArray":
        return "[" + ", ".join(emit_ast(a) for a in args) + "]"
    if name == "createObject":
        return "{" + ", ".join(f"{emit_ast(args[i])} = {emit_ast(args[i+1])}" for i in range(0, len(args), 2)) + "}"
    if name == "array":
        return f"[{emit_ast(args[0])}]"
    if name == "last":
        x = emit_ast(args[0]); return f"{x}[length({x}) - 1]"
    if name == "take":
        return f"substr({emit_ast(args[0])}, 0, {emit_ast(args[1])})"
    if name == "resourceId":
        prefix = ['data.azurerm_resource_group.target.id']
        offset = 0
        if not isinstance(args[0], ast.Constant):
            if len(args) > 2 and not isinstance(args[1], ast.Constant):
                prefix = [quoted('/subscriptions'), emit_ast(args[0]), quoted('resourceGroups'), emit_ast(args[1])]
                offset = 2
            else:
                prefix = [quoted('/subscriptions'), 'data.azurerm_subscription.current.subscription_id', quoted('resourceGroups'), emit_ast(args[0])]
                offset = 1
        resource_type = ast.literal_eval(args[offset])
        parts = resource_type.split("/")
        if len(parts) - 1 != len(args) - offset - 1:
            raise Unsupported("resourceId with nonliteral or mismatched names")
        segments = prefix + [quoted("providers"), quoted(parts[0])]
        for typ, value in zip(parts[1:], args[offset + 1:]):
            segments += [quoted(typ), emit_ast(value)]
        return "join(\"/\", [" + ", ".join(segments) + "])"
    if name == "union":
        return "merge(" + ", ".join(emit_ast(a) for a in args) + ")"
    supported = {"length", "replace", "split", "contains", "format", "lower", "jsondecode", "tostring", "tonumber", "tobool"}
    if name not in supported:
        raise Unsupported(f"function {name}")
    return f"{name}(" + ", ".join(emit_ast(a) for a in args) + ")"


def emit_ast(node):
    if isinstance(node, ast.Constant):
        return quoted(node.value)
    if isinstance(node, ast.Name):
        if node.id in ("true", "false", "null"):
            return node.id
        raise Unsupported(f"name {node.id}")
    if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
        return call(node.func.id, node.args)
    if isinstance(node, ast.Attribute):
        base = emit_ast(node.value)
        key = {"subscriptionId": "subscription_id"}.get(node.attr, node.attr)
        return f"{base}.{key}"
    if isinstance(node, ast.Subscript):
        return f"{emit_ast(node.value)}[{emit_ast(node.slice)}]"
    if isinstance(node, ast.List):
        return "[" + ", ".join(emit_ast(x) for x in node.elts) + "]"
    raise Unsupported(f"syntax {ast.dump(node)}")


def expression(value):
    if not (value.startswith("[") and value.endswith("]")):
        return quoted(value)
    code = value[1:-1]
    for keyword in ("if", "and", "or", "not"):
        code = re.sub(rf"\b{keyword}\s*\(", f"_{keyword}(", code)
    try:
        return emit_ast(ast.parse(code, mode="eval").body)
    except (SyntaxError, ValueError, IndexError, TypeError) as exc:
        raise Unsupported(f"expression {value}: {exc}") from exc


def emit(value):
    if isinstance(value, str):
        return expression(value)
    if isinstance(value, (bool, int, float)) or value is None:
        return json.dumps(value)
    if isinstance(value, list):
        return "[" + ", ".join(emit(x) for x in value) + "]"
    if isinstance(value, dict):
        return "{" + ", ".join(f"{quoted(k)} = {emit(v)}" for k, v in value.items()) + "}"
    raise Unsupported(f"value {value!r}")


def convert(path):
    global PARAMETER_NAMES, VARIABLE_NAMES, ARRAY_PARAMETERS, ARRAY_VARIABLES, PARAMETER_DYNAMIC_DEFAULTS
    text = path.read_text(encoding="utf-8-sig")
    data = json.loads(re.sub(r",\s*([}\]])", r"\1", text))
    PARAMETER_NAMES = {key.casefold(): key for key in data.get("parameters", {})}
    VARIABLE_NAMES = {key.casefold(): key for key in data.get("variables", {})}
    ARRAY_PARAMETERS = {key.casefold() for key, value in data.get("parameters", {}).items() if value["type"].lower() == "array"}
    ARRAY_VARIABLES = {key.casefold() for key, value in data.get("variables", {}).items() if isinstance(value, list)}
    def contains_expression(value):
        if isinstance(value, str):
            return value.startswith("[") and value.endswith("]")
        if isinstance(value, list):
            return any(contains_expression(x) for x in value)
        if isinstance(value, dict):
            return any(contains_expression(x) for x in value.values())
        return False
    PARAMETER_DYNAMIC_DEFAULTS = {key.casefold(): value["defaultValue"] for key, value in data.get("parameters", {}).items() if "defaultValue" in value and contains_expression(value["defaultValue"])}
    resources = data.get("resources", [])
    if len(resources) != 1:
        raise Unsupported("requires exactly one resource")
    resource = resources[0]
    if any(x in resource for x in ("copy", "condition", "dependsOn", "resources")):
        raise Unsupported("resource has loop, condition or dependency")
    type_parts = resource["type"].split("/")
    if "providers" in type_parts[1:]:
        raise Unsupported("extension resource requires explicit scope")
    if any(k in resource for k in ("scope", "subscriptionId", "resourceGroup")):
        raise Unsupported("resource scope override")
    body = {k: v for k, v in resource.items() if k not in ("type", "apiVersion", "name", "location", "tags")}
    if any(k in body for k in ("copy", "condition")):
        raise Unsupported("body has loop or condition")
    rel = path.relative_to(SOURCE).with_suffix("")
    out_dir = DEST / rel
    declarations = [
        'terraform {\n  required_providers {\n    azapi = { source = "Azure/azapi", version = "~> 2.0" }\n    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }\n  }\n}',
        'data "azurerm_resource_group" "target" { name = var.resource_group_name }',
        'data "azurerm_subscription" "current" {}',
        'variable "resource_group_name" { type = string }',
    ]
    types = {"string": "string", "securestring": "string", "int": "number", "bool": "bool", "array": "list(any)", "object": "any", "secureobject": "any"}
    for name, info in data.get("parameters", {}).items():
        bits = [f'type = {types[info["type"].lower()]}']
        if "defaultValue" in info:
            bits.append("default = " + ("null" if name.casefold() in PARAMETER_DYNAMIC_DEFAULTS else emit(info["defaultValue"])))
        if info["type"].lower().startswith("secure"):
            bits.append("sensitive = true")
        if info.get("metadata", {}).get("description"):
            bits.append("description = " + quoted(info["metadata"]["description"]))
        checks = []
        if "allowedValues" in info:
            allowed = f"contains({emit(info['allowedValues'])}, var.{name})"
            if "defaultValue" in info and info["defaultValue"] not in info["allowedValues"]:
                allowed = f"({allowed} || var.{name} == {emit(info['defaultValue'])})"
            checks.append(allowed)
        for key, op, func in (("minValue", ">=", ""), ("maxValue", "<=", ""), ("minLength", ">=", "length"), ("maxLength", "<=", "length")):
            if key in info:
                subject = f"length(var.{name})" if func else f"var.{name}"
                checks.append(f"{subject} {op} {info[key]}")
        if checks:
            condition = ' && '.join(f'({c})' for c in checks)
            if name.casefold() in PARAMETER_DYNAMIC_DEFAULTS:
                condition = f"var.{name} == null ? true : ({condition})"
            bits.append('validation {\n    condition = ' + condition + '\n    error_message = "Value must meet the ARM parameter constraints."\n  }')
        declarations.append(f'variable "{name}" {{\n  ' + "\n  ".join(bits) + "\n}")
    if data.get("variables"):
        declarations.append("locals {\n" + "\n".join(f"  {k} = {emit(v)}" for k, v in data["variables"].items()) + "\n}")
    full_name = emit(resource["name"])
    if len(type_parts) == 2:
        parent = 'data.azurerm_resource_group.target.id'
        short_name = full_name
    else:
        declarations.append(f'locals {{ resource_name_parts = split("/", {full_name}) }}')
        expected = len(type_parts) - 1
        declarations.append(f'check "resource_name_segments" {{\n  assert {{\n    condition = length(local.resource_name_parts) == {expected}\n    error_message = "ARM resource name must contain {expected} segments."\n  }}\n}}')
        parent_parts = ['data.azurerm_resource_group.target.id', quoted('providers'), quoted(type_parts[0])]
        for i, segment in enumerate(type_parts[1:-1]):
            parent_parts.extend([quoted(segment), f'local.resource_name_parts[{i}]'])
        parent = 'join("/", [' + ', '.join(parent_parts) + '])'
        short_name = f'local.resource_name_parts[{expected - 1}]'
    pieces = [f'type = {quoted(resource["type"] + "@" + resource["apiVersion"])}',
              'parent_id = ' + parent,
              'name = ' + short_name]
    if resource["type"] in ("Microsoft.Web/sites/hostnameBindings", "Microsoft.ContainerService/managedClusters/agentPools", "microsoft.alertsmanagement/smartdetectoralertrules"):
        pieces.append("schema_validation_enabled = false")
    for key in ("location", "tags"):
        if key in resource:
            pieces.append(f"{key} = {emit(resource[key])}")
    pieces.append("body = " + emit(body))
    declarations.append('resource "azapi_resource" "main" {\n  ' + "\n  ".join(pieces) + "\n}")
    for name, info in data.get("outputs", {}).items():
        declarations.append(f'output "{name}" {{ value = {emit(info["value"])} }}')
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "main.tf").write_text("\n\n".join(declarations) + "\n", encoding="utf-8")
    return str(rel).replace("\\", "/")


if __name__ == "__main__":
    success, errors = [], {}
    for source in sorted(SOURCE.rglob("*.json")):
        try:
            success.append(convert(source))
        except (Unsupported, KeyError, json.JSONDecodeError) as exc:
            errors[str(source.relative_to(SOURCE)).replace("\\", "/")] = str(exc)
    (DEST / "conversion-status.json").write_text(json.dumps({"native": success, "pending": errors}, indent=2) + "\n", encoding="utf-8")
    print(f"Generated {len(success)} native AzAPI modules; {len(errors)} require manual conversion")
