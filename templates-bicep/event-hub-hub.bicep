param hubName string
param eventHubNamespaceName string

@minValue(1)
@maxValue(7)
param messageRetentionInDays int = 1

@minValue(2)
@maxValue(32)
param partitionCount int = 4

resource eventHubNamespaceName_hub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
  name: '${eventHubNamespaceName}/${hubName}'
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
  }
}

resource eventHubNamespaceName_hubName_ReadWrite 'Microsoft.EventHub/namespaces/eventhubs/AuthorizationRules@2017-04-01' = {
  parent: eventHubNamespaceName_hub
  name: 'ReadWrite'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource eventHubNamespaceName_hubName_Read 'Microsoft.EventHub/namespaces/eventhubs/AuthorizationRules@2017-04-01' = {
  parent: eventHubNamespaceName_hub
  name: 'Read'
  properties: {
    rights: [
      'Listen'
    ]
  }
  dependsOn: [
    eventHubNamespaceName_hubName_ReadWrite
  ]
}

output HubEndpoint string = listkeys(eventHubNamespaceName_hubName_ReadWrite.id, '2017-04-01').primaryConnectionString
output HubEndpointReadOnly string = listkeys(eventHubNamespaceName_hubName_Read.id, '2017-04-01').primaryConnectionString
