# das-platform-building-blocks

## Usage

1. Get the 'Raw' path for the Azure Resource template you wish to use. (eg https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/app-service.json)

2. Plug this into your ARM template as follows:

```json
{
    "apiVersion": "2017-05-10",
    "name": "<Name for the resource deployment>",
    "type": "Microsoft.Resources/deployments",
    "properties": {
        "mode": "Incremental", //or Complete
        "templateLink": {
            "uri": "<Template Raw Url from Step 1>",
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