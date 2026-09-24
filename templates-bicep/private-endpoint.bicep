@description('Name used for private endpoint')
param privateEndpointName string

@description('ResourceId of the subnet to associate with the private endpoint')
param subnetId string

@description('The resource id of private link service. i.e sqlServer')
param privateLinkGroupIds array

@description('ResourceId of the resource to link the private endpoint is for')
param privateLinkServiceId string

@description('ResourceId of the private dns zone to associate with')
param privateDnsZoneId string = ''

@description('Boolean flag to determine manual or automatic private endpoint approval')
param manualApproval bool = false

var privateEndpointServiceConnectionType = (manualApproval
  ? 'manualPrivateLinkServiceConnections'
  : 'privateLinkServiceConnections')

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: resourceGroup().location
  tags: {}
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    '${privateEndpointServiceConnectionType}': [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: privateLinkGroupIds
          requestMessage: 'Requested via private endpoint deployment: ${privateEndpointName}'
        }
      }
    ]
  }
}

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = if (length(privateDnsZoneId) > 0) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateEndpointName
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
