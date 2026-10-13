@description('The id of the action group to send the alert to as outputed by action-group.json.')
param actionGroupId string

@description('A friendly description for the alert.')
param alertDescription string

@description('The frequency that the queryMetricThreshold is assessed.')
param alertFrequency int

@description('The subject of the alert email (this may also be visible in other action group types).')
param alertMessageSubject string

@description('The timespan over which to measure the queryMetricThreshold.')
param alertPeriod int

@description('The name of the Azure Resource Manager resource that represents the alert.')
param alertResourceName string

@description('The operator used to assess the queryMetricThreshold against the query result. Must be one of the metricTrigger thresholdOperator values supported by scheduledQueryRules (Equal, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual).')
@allowed([
  'Equal'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param alertTriggerOperator string

@description('Whether to trigger the alert based on the total number of breaches or the consecutive number.')
@allowed([
  'Consecutive'
  'Total'
])
param alertTriggerMetricTriggerType string

@description('The threshold for the trigger.')
param alertTriggerThreshold int

@description('The kusto query used to retrieve the query metric.')
param kustoQuery string

@description('The id of the log analytics workspace as outputed by log-analtyics-workspace.json.')
param logAnalyticsId string

@description('The threshold used to assess the results of the kusto query.')
param queryMetricThreshold int

@description('The alert severity, used to group alerts by Azure.')
@minValue(0)
@maxValue(4)
param severity int
param enableAlert bool = true

@description('The operator used to assess the results of the kusto query against the threshold.')
@allowed([
  'Equal'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param queryMetricThresholdOperator string = 'GreaterThan'

@description('Optional additional action group ids to invoke alongside actionGroupId, for example a group that triggers a remediation Logic App. Kept separate so a shared notification group can still be passed as actionGroupId.')
param additionalActionGroupIds array = []

@description('When true, the alert is automatically resolved once the query stops breaching, sending a resolved notification to the action groups. Defaults to false to preserve the existing fire-only behaviour of alerts that do not opt in.')
param autoMitigate bool = false

var alertActionBase = {
  'odata.type': 'Microsoft.WindowsAzure.Management.Monitoring.Alerts.Models.Microsoft.AppInsights.Nexus.DataContracts.Resources.ScheduledQueryRules.AlertingAction'
  severity: string(severity)
  aznsAction: {
    actionGroup: concat(array(actionGroupId), additionalActionGroupIds)
    emailSubject: alertMessageSubject
  }
  trigger: {
    thresholdOperator: queryMetricThresholdOperator
    threshold: queryMetricThreshold
    metricTrigger: {
      thresholdOperator: alertTriggerOperator
      threshold: alertTriggerThreshold
      metricTriggerType: alertTriggerMetricTriggerType
    }
  }
}

resource alertResource 'microsoft.insights/scheduledQueryRules@2018-04-16' = {
  name: alertResourceName
  location: resourceGroup().location
  properties: {
    description: alertDescription
    enabled: enableAlert
    autoMitigate: autoMitigate
    source: {
      query: kustoQuery
      dataSourceId: logAnalyticsId
      queryType: 'ResultCount'
    }
    schedule: {
      frequencyInMinutes: alertFrequency
      timeWindowInMinutes: alertPeriod
    }
    action: union(alertActionBase, (autoMitigate ? json('{}') : json('{"throttlingInMin": 20}')))
  }
}
