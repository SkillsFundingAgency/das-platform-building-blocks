@description('The name of the Container Registry.')
param registryName string

@allowed([
  ''
  'Classic'
  'Basic'
  'Standard'
  'Premium'
])
param registrySkuName string = ''

@description('A list of subnet resource ids.')
param subnetResourceIdList array = []

@description('A list of allowed IPs')
param allowedIpAddressesList array = []
param adminUserEnabled bool = false

var virtualNetworkRulesArray = [
    for j in range(0, ((length(subnetResourceIdList) > 0) ? length(subnetResourceIdList) : 1)): {
      id: ((length(subnetResourceIdList) > 0) ? subnetResourceIdList[j] : json('null'))
      action: 'Allow'
    }
  ]
var virtualNetworkRules = {
  virtualNetworkRules: virtualNetworkRulesArray
}
var ipRulesArray = [
    for j in range(0, ((length(allowedIpAddressesList) > 0) ? length(allowedIpAddressesList) : 1)): {
      value: ((length(allowedIpAddressesList) > 0) ? allowedIpAddressesList[j] : json('null'))
      action: 'Allow'
    }
  ]
var ipRules = {
  ipRules: ipRulesArray
}
var networkRuleSet = {
  virtualNetworkRules: ((length(subnetResourceIdList) > 0) ? virtualNetworkRules.virtualNetworkRules : json('null'))
  ipRules: ((length(allowedIpAddressesList) > 0) ? ipRules.ipRules : json('null'))
  defaultAction: 'Deny'
}

resource registry 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  location: resourceGroup().location
  name: registryName
  sku: {
    name: registrySkuName
  }
  properties: {
    networkRuleSet: (((length(subnetResourceIdList) > 0) || (length(allowedIpAddressesList) > 0))
      ? networkRuleSet
      : json('null'))
    adminUserEnabled: adminUserEnabled
  }
}

output acrResourceId string = registry.id
