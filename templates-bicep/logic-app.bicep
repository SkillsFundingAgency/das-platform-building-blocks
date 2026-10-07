@description('Name of the Logic App (workflow).')
param logicAppName string

@description('Location for the Logic App.')
param location string = resourceGroup().location

@description('Tags to apply to the Logic App.')
param tags object = {}

@description('Managed identity type for the Logic App. Use SystemAssigned when the workflow needs to authenticate to Azure resources; the identity\'s principalId is returned as an output.')
@allowed([
  'SystemAssigned'
  'None'
])
param identityType string = 'SystemAssigned'

@description('Whether the Logic App is enabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Enabled'

@description('The Logic App workflow definition object (schema, triggers, actions, outputs).')
param workflowDefinition object

@description('Values for the workflow definition parameters, in the form { paramName: { value: ... } }.')
param workflowParameters object = {}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: tags
  identity: {
    type: identityType
  }
  properties: {
    state: state
    definition: workflowDefinition
    parameters: workflowParameters
  }
}

output logicAppResourceId string = logicApp.id
output principalId string = ((identityType == 'SystemAssigned')
  ? reference(logicApp.id, '2019-05-01', 'Full').identity.principalId
  : '')
