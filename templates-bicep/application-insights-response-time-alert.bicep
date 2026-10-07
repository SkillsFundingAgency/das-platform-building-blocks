param enabled bool = true

@description('The web app name that the alert is applied for')
param serviceName string

@description('The application insights resource ID that the alert is applied on')
param applicationInsightsResourceId string

@description('The id of the action group to send the alert to.')
param alertActionGroupResourceId string

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 1

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
param windowSize string = 'PT30M'

@description('How often the metric alert is evaluated. ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT1M'

@description('An array of metric dimensions used to filter the metric being alerted on')
@metadata({
  documentation: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/metricalerts?tabs=json#metricdimension'
})
param dimensions array = [
  {
    name: 'cloud/roleName'
    operator: 'Include'
    values: [
      serviceName
    ]
  }
]

@description('The Dynamic threshold sensitivity')
param alertSensitivity string = 'Medium'
param numberOfEvaluationPeriods int = 1
param minFailingPeriodsToAlert int = 1

var alertName = '${serviceName} Response Time Alert'

resource alert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  tags: {}
  properties: {
    severity: alertSeverity
    enabled: enabled
    scopes: [
      applicationInsightsResourceId
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          alertSensitivity: alertSensitivity
          failingPeriods: {
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
          }
          name: 'responseTime'
          metricNamespace: 'microsoft.insights/components'
          metricName: 'requests/duration'
          dimensions: dimensions
          operator: 'GreaterThan'
          timeAggregation: 'Maximum'
          skipMetricValidation: false
          criterionType: 'DynamicThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'microsoft.insights/components'
    targetResourceRegion: 'westeurope'
    actions: [
      {
        actionGroupId: alertActionGroupResourceId
        webHookProperties: {}
      }
    ]
  }
}
