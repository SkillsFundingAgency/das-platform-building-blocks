param namespaceLocation string
param namespaceName string
param notificationHubName string
param sku string = 'Free'
param tags object = {}
param replicationRegion string = 'default'
param zoneRedundancy string = 'Disabled'

resource namespace 'Microsoft.NotificationHubs/namespaces@2023-10-01-preview' = {
  name: namespaceName
  location: namespaceLocation
  sku: {
    name: sku
  }
  properties: {
    replicationRegion: replicationRegion
    zoneRedundancy: zoneRedundancy
  }
  tags: tags
}

resource namespaceName_notificationHub 'Microsoft.NotificationHubs/namespaces/notificationHubs@2023-10-01-preview' = {
  parent: namespace
  name: '${notificationHubName}'
  location: namespaceLocation
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    name: notificationHubName
  }
}
