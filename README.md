# das-platform-building-blocks

## Usage

1. Set the root 'Raw' path of the Azure Resource templates as a top-level variable as follows:

```json
"variables": {
        "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/",
        ...
}
```
2. Select the Azure Resource template you wish to use, (eg. https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/app-service.json) by setting the concatenation of the deploymentUrlBase variable and the file name as the uri of the templateLink property as follows:

```json
{
    "apiVersion": "2017-05-10",
    "name": "<Name for the resource deployment>",
    "type": "Microsoft.Resources/deployments",
    "properties": {
        "mode": "Incremental", //or Complete
        "templateLink": {
            "uri": "[concat(variables('deploymentUrlBase'),'app-service.json')]",
            "contentVersion": "1.0.0.0"
        },
        "parameters": {
            "Parameter1": {
                "value": "<Your value>"
            },
            "Parameter2": {
                "value": "<Your value>"
            }
        }
    },
    "dependsOn":[
        "<Any dependencies>"
    ]
}
```
## Azure resource naming

Reduce the number of top-level parameters needed by setting the Azure resource names with variables:

1. Set the top-level resourceEnvironmentName parameter as follows:

    ```json
    "parameters": {
        "resourceEnvironmentName": {
                "type": "string"
            },
            ...
    }
    ```
2. Set the top-level variable of the resourceNamePrefix and Azure resource names as follows:

    ```json
    "variables": {
        ...
        "resourceNamePrefix": "[toLower(concat('das-', parameters('resourceEnvironmentName')))]",
        "appServiceName": "[concat(variables('resourceNamePrefix'), '-<service abbreviation>-as')]",
        ...
    }
    ```
3. Within the properties section of the resource deployment section use the resource name variable for the name parameter of the resource as follows:

    ```json
    "parameters": {
        "appServiceName": {
            "value": "[variables('appServiceName')]"
        },
        ...
    }
    ```