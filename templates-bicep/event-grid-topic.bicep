@description('Name of the Event Grid custom topic to create.')
param topicName string

@description('Location of the topic. For Defender malware scan results this must match the region of the storage account whose results it receives.')
param location string = resourceGroup().location

@description('Schema in which events are published to the topic.')
@allowed([
  'EventGridSchema'
  'CloudEventSchemaV1_0'
  'CustomEventSchema'
])
param inputSchema string = 'EventGridSchema'

@description('Whether the topic accepts traffic from public IPs. Defender for Storage cannot publish to a topic that only allows private endpoints, so this must be Enabled for malware scan results.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

resource topic 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: topicName
  location: location
  properties: {
    inputSchema: inputSchema
    publicNetworkAccess: publicNetworkAccess
  }
}

output topicName string = topicName
output topicResourceId string = topic.id
