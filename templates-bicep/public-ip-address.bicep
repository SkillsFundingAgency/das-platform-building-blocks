@description('The name of the public ip address resource')
param publicIPAddressName string

@description('The name of the public ip address resource See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm for more information')
@allowed([
  'Basic'
  'Standard'
])
param sku string = 'Basic'

@description('The public IP address allocation method')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string = 'Static'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-04-01' = {
  name: publicIPAddressName
  location: resourceGroup().location
  sku: {
    name: sku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

output PublicIPAddress string = reference(
  publicIPAddress.id,
  providers('Microsoft.Network', 'publicIPAddresses').apiVersions[0]
).ipAddress
output PublicIpAddressResourceId string = publicIPAddress.id
