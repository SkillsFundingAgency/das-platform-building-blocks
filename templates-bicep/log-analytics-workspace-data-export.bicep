param logAnalyticsWorkspaceName string

@minLength(4)
@maxLength(63)
param dataExportRuleName string
param destinationResourceId string = ''
param eventHubName string = ''
param tableNames array = []
param enable bool = true

var deployRule = ((length(tableNames) > 0) && (!empty(destinationResourceId)))
var destination = {
  resourceId: destinationResourceId
  metaData: (empty(eventHubName)
    ? json('null')
    : {
        eventHubName: eventHubName
      })
}

resource logAnalyticsWorkspaceName_dataExportRule 'Microsoft.OperationalInsights/workspaces/dataExports@2023-09-01' = if (deployRule) {
  name: '${logAnalyticsWorkspaceName}/${dataExportRuleName}'
  properties: {
    destination: destination
    tableNames: tableNames
    enable: enable
  }
}

output dataExportRuleDeployed bool = deployRule
