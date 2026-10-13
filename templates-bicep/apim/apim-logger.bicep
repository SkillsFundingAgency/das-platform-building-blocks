param apimName string
param loggerName string

@allowed([
  'azureEventHub'
  'applicationInsights'
])
param loggerType string
param loggerCredentials object
param loggerResourceId string

resource apimName_logger 'Microsoft.ApiManagement/service/loggers@2019-12-01' = {
  name: '${apimName}/${loggerName}'
  properties: {
    loggerType: loggerType
    description: loggerName
    credentials: loggerCredentials
    resourceId: loggerResourceId
  }
}

resource apimName_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2019-12-01' = {
  name: '${apimName}/applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apimName_logger.id
    sampling: {
      samplingType: 'fixed'
      percentage: 50
    }
  }
}
