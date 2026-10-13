@description('The name of the application insights instance')
param appInsightsName string

@description('The resource group that contains the application insights instance')
param appInsightsResourceGroup string = resourceGroup().name

@description('The resource id of the action group to associate with this alert')
param actionGroupResourceId string

@description('The severity of the alert')
param severity string = 'Sev2'

resource Failure_Anomalies_appInsights 'microsoft.alertsmanagement/smartdetectoralertrules@2019-03-01' = {
  name: 'Failure Anomalies - ${appInsightsName}'
  location: 'global'
  properties: {
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    state: 'Enabled'
    severity: severity
    frequency: 'PT1M'
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      resourceId(appInsightsResourceGroup, 'Microsoft.Insights/components', appInsightsName)
    ]
    actionGroups: {
      groupIds: [
        actionGroupResourceId
      ]
    }
  }
}
