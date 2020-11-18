# Platform Building Blocks: Styles and Conventions

## Table of contents
1. [Usage](#Usage)
2. [Branching](#Branching)
3. [Resource naming and parameter metadata description properties](#Resource-naming-and-parameter-metadata-description-properties)
4. [Property name formatting](#Property-name-formatting)
5. [GitHub Releases and Versioning](#GitHub-Releases-and-Versioning)

### Usage

1. In the root of the applications repository, create a new directory named `azure`

2. Within the directory Create a new template named `template.json`


2. Set the root 'Raw' path of the Azure Resource templates as a top-level variable as follows:

    ```json
    "variables": {
            "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/"
    }
    ```

3. Select the Azure Resource template you wish to use, (eg. https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/app-service-v2.json) by setting the concatenation of the deploymentUrlBase variable and the file name as the uri of the templateLink property as follows:

    ```json
    {
        "apiVersion": "2017-05-10",
        "name": "app-service",
        "type": "Microsoft.Resources/deployments",
        "properties": {
            "mode": "Incremental", //or Complete
            "templateLink": {
                "uri": "[concat(variables('deploymentUrlBase'),'app-service-v2.json')]",
                "contentVersion": "1.0.0.0"
            },
            "parameters": {
                "parameter1": {
                    "value": "<Your value>"
                },
                "parameter2": {
                    "value": "<Your value>"
                }
            }
        },
        "dependsOn":[
            "<Any dependencies>"
        ]
    }
    ```

## Branching

1. Always do your work in a new branch.

2. Do not ever commit straight to master.

3. Submit a pull request to the team when you are ready for review.

4. After the pull request is approved and the branch merged to master, delete the branch you made.

## Resource naming and parameter metadata description properties

Reduce the number of top-level parameters needed by setting the Azure resource names with variables:

1. Set the top-level ```resourceEnvironmentName``` and ```serviceName``` parameters as follows, adding a metadata description property to all top-level parameters:

    ```json
    "parameters": {
        "resourceEnvironmentName": {
            "type": "string",
            "metadata": {
                "description": "Short name of the environment. Used for the name of resources created."
            }
        },
        "serviceName": {
            "type": "string",
            "metadata": {
                "description": "Short name of the service. Used for the name of resources created."
            }
        },
            ...
    }
    ```

2. Set the top-level variable of the ```resourceNamePrefix``` and Azure resource names as follows:

    ```json
    "variables": {
        ...
        "resourceNamePrefix": "[toLower(concat('das-', parameters('resourceEnvironmentName'),'-', parameters('serviceName')))]",
        "storageAccountName": "[toLower(concat('das', parameters('resourceEnvironmentName'), parameters('serviceName'), 'str'))]",
        "appServiceName": "[concat(variables('resourceNamePrefix'), '-as')]",
        ...
    }
    ```
3. Within the properties section of the resource deployment section, use the resource name variable for the name parameter of the resource as follows:

    ```json
    "parameters": {
        "appServiceName": {
            "value": "[variables('appServiceName')]"
        },
        ...
    }
    ```
4. Set the the top-level output of the generated variable that will be used in the release pipeline as follows:

    ```json
    "outputs": {
        "AppServiceName": {
            "type": "string",
            "value": "[variables('appServiceName')]"
        },
        ...
    }
    ```
## Property name formatting

The convention of property name formatting, as used in the examples above:

1. Parameters: camelCase (matching the release pipeline override template parameters)
2. Variables: camelCase
3. Resource Deployments: lowercase-with-hyphens
4. Outputs: PascalCase (matching the release pipeline variables)

## GitHub Releases and Versioning

This section provides an overview of the following:

| Section Header | Description |
| - | - |
| GitHub Releases | This section provides an overview of the das-platform-building-blocks repository release, how to approve a release to GitHub and how to use the Azure DevOps GitHub Release Task within a release pipeline. |
| Release Versioning | This section provides an overview of how to ensure a consistent release versioning policy is used, and GitHub releases are appropriately incremented. |

### GitHub Releases

The das-platform-building-blocks repository is published as a release on GitHub.com. Releases provide a list of changes made to a specific release as well as links to the assets available. Using GitHub releases enables the use of the Azure DevOps GitHub Release Task so that the templates in das-platform-building-blocks can be consumed within Azure Pipeline deployments.

### Release Versioning

To ensure a consistent release versioning policy the following can be used as a reference:

| Increment Type | When to use | How to use |
| -- | -- | -- |
| Major | Breaking changes to scripts | Add `+semver: major` to pull request title. |
| Minor | Addition of new scripts | Add `+semver: minor` to pull request title. |
| Patch | Non-breaking changes to existing scripts | Automatically incremented for every merge if a major or minor is not defined. |

[GitVersion](https://gitversion.readthedocs.io/en/latest/) is used to achieve release versioning. Read more about [Version Incrementing](https://gitversion.readthedocs.io/en/latest/more-info/version-increments/).