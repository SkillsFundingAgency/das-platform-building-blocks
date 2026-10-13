param principalId string

@allowed([
  'ServiceBusOwner'
  'ServiceBusReceiver'
  'ServiceBusSender'
  'ServiceBusReader'
])
param assignmentType string
param resourceName string

var ServiceBusOwner = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/090c5cfd-751d-490a-894a-3ce6f1109419'
var ServiceBusReceiver = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
var ServiceBusSender = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
var ServiceBusReader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource resourceName_Microsoft_Authorization_principalId_resourceName_assignmentType_ServiceBusOwner_ServiceBusOwner_assignmentType_ServiceBusReceiver_ServiceBusReceiver_assignmentType_ServiceBusSender_ServiceBusSender_ServiceBusReader 'Microsoft.ServiceBus/namespaces/providers/roleAssignments@2018-09-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId,resourceName,last(split(((assignmentType=='ServiceBusOwner')?ServiceBusOwner:((assignmentType=='ServiceBusReceiver')?ServiceBusReceiver:((assignmentType=='ServiceBusSender')?ServiceBusSender:ServiceBusReader))),'/'))))}'
  properties: {
    roleDefinitionId: ((assignmentType == 'ServiceBusOwner')
      ? ServiceBusOwner
      : ((assignmentType == 'ServiceBusReceiver')
          ? ServiceBusReceiver
          : ((assignmentType == 'ServiceBusSender') ? ServiceBusSender : ServiceBusReader)))
    principalId: principalId
  }
}
