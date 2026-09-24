@description('Name of the application insights resource')
param appInsightsName string
param attachedService string = ''
param logAnalyticsWorkspaceId string = ''

var baseProperties = {
  Application_Type: 'web'
}
var logAnalyticsWorkspaceProperties = {
  WorkspaceResourceId: logAnalyticsWorkspaceId
}
var useWorkspace = (length(logAnalyticsWorkspaceId) > 0)
var appInsightsProperties = (useWorkspace ? union(baseProperties, logAnalyticsWorkspaceProperties) : baseProperties)

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites',attachedService)}': 'Resource'
  }
  properties: appInsightsProperties
}

output InstrumentationKey string = appInsights.properties.InstrumentationKey
output AppId string = appInsights.properties.AppId
output AppInsightsResourceId string = appInsights.id
output ConnectionString string = appInsights.properties.ConnectionString
