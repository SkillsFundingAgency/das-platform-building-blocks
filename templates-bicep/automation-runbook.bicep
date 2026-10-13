param automationAccountName string

param runbookName string

param location string = resourceGroup().location

@allowed([
  ''
  'Graph'
  'GraphPowerShell'
  'GraphPowerShellWorkflow'
  'PowerShell'
  'PowerShell72'
  'PowerShellWorkflow'
  'Python'
  'Python2'
  'Python3'
  'Script'
])
param runbookType string = ''

param description string = ''

param logVerbose bool = false

param logProgress bool = false

@minValue(0)
@maxValue(3)
param logActivityTrace int = 0

param publishContentUri string

param publishContentVersion string = '1.0.0.0'

resource automationAccountName_runbook 'Microsoft.Automation/automationAccounts/runbooks@2024-10-23' = {
  name: '${automationAccountName}/${runbookName}'
  location: location
  properties: {
    description: description
    logVerbose: logVerbose
    logProgress: logProgress
    logActivityTrace: logActivityTrace
    runbookType: runbookType
    publishContentLink: {
      uri: publishContentUri
      version: publishContentVersion
    }
  }
}

output runbookResourceId string = automationAccountName_runbook.id
