@description('Name of metric alert.')
param alertName string

@description('Description of metric alert.')
param alertDescription string = ''

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 3

@description('Specifies whether the alert is enabled.')
param isEnabled bool = true

@description('Type of target resource.')
@allowed([
  'microsoft.insights/components'
  'Microsoft.DataFactory/factories'
  'Microsoft.Network/applicationGateways'
])
param targetResourceType string = 'microsoft.insights/components'

@description('The list of resource id\'s that this metric alert is scoped to, e.g. list of Application Insights resources.')
param resourceIdScopeList array

@description('Namespace of the metric.')
@allowed([
  'microsoft.insights/components'
  'Microsoft.DataFactory/factories'
  'Microsoft.Network/applicationGateways'
])
param metricNamepace string = 'microsoft.insights/components'

@description('Name of the metric, dependent on the metric namespace. E.g. \'dependencies/failed\' for \'microsoft.insights/components\' namespace.')
param metricName string

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'Equals'
  'NotEquals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param metricOperator string = 'GreaterThan'

@description('The threshold value that activates the alert.')
param metricThreshold int

@description('How the data that is collected should be combined over time.')
@allowed([
  'Average'
  'Minimum'
  'Maximum'
  'Total'
  'Count'
])
param timeAggregation string = 'Count'

@description('Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day. ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
  'PT6H'
  'PT12H'
  'P1D'
])
param windowSize string = 'PT5M'

@description('How often the metric alert is evaluated. ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT1M'

@description('The id of the action group to send the alert to.')
param actionGroupResourceId string

@description('An optional array of metric dimensions used to filter the metric being alerted on')
@metadata({
  documentation: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/metricalerts?tabs=json#metricdimension'
})
param dimensions array = []

resource alert 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  tags: {}
  properties: {
    description: alertDescription
    severity: alertSeverity
    enabled: isEnabled
    scopes: resourceIdScopeList
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: metricThreshold
          name: 'Metric1'
          metricNamespace: metricNamepace
          metricName: metricName
          dimensions: dimensions
          operator: metricOperator
          timeAggregation: timeAggregation
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
    targetResourceType: targetResourceType
    actions: [
      {
        actionGroupId: actionGroupResourceId
      }
    ]
  }
}
