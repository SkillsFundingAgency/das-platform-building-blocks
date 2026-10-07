param apimName string
param logAnalyticsWorkspaceResourceGroup string
param logAnalyticsWorkspaceName string
param logsRetentionDays int = 30

resource apimName_Microsoft_Insights_service 'Microsoft.ApiManagement/service/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${apimName}/Microsoft.Insights/service'
  properties: {
    workspaceId: resourceId(
      logAnalyticsWorkspaceResourceGroup,
      'Microsoft.OperationalInsights/workspaces',
      logAnalyticsWorkspaceName
    )
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionDays
        }
      }
    ]
  }
}
