@description('The name of the virtual network to create the subnet in.')
param virtualNetworkName string

@description('The name of the subnet.')
param subnetName string

@description('The address prefix of the subnet.')
param subnetAddressPrefix string

@description('A list of service endpoints.')
param serviceEndpointList array = []

@description('An array of delegations. Object reference can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/virtualnetworks/subnets#Delegation')
param delegations array = []

@description('An object of the route table. Object reference can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/virtualnetworks/subnets#routetable-object')
param routeTable object = {}

@description('An object of the Network Security Group. Object reference can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/virtualnetworks/subnets#NetworkSecurityGroup')
param networkSecurityGroup object = {}

var serviceEndPointsEmpty = []
var networkSecurityGroupSubnetProperty = {
  networkSecurityGroup: networkSecurityGroup
}
var routeTableSubnetProperty = {
  routeTable: routeTable
}
var baseSubnetProperties = {
  addressPrefix: subnetAddressPrefix
  serviceEndpoints: ((length(serviceEndpointList) > 0) ? serviceEndPoints : serviceEndPointsEmpty)
  delegations: delegations
}
var networkSecurityGroupIncludedSubnetProperties = (empty(networkSecurityGroup)
  ? baseSubnetProperties
  : union(baseSubnetProperties, networkSecurityGroupSubnetProperty))
var subnetProperties = (empty(routeTable)
  ? networkSecurityGroupIncludedSubnetProperties
  : union(networkSecurityGroupIncludedSubnetProperties, routeTableSubnetProperty))
var serviceEndPoints = [
  for i in range(0, ((length(serviceEndpointList) > 0) ? length(serviceEndpointList) : 1)): {
    service: ((length(serviceEndpointList) > 0) ? serviceEndpointList[i] : json('null'))
  }
]

resource virtualNetworkName_subnet 'Microsoft.Network/virtualNetworks/subnets@2018-11-01' = {
  name: '${virtualNetworkName}/${subnetName}'
  properties: subnetProperties
}

output SubnetResourceId string = virtualNetworkName_subnet.id
