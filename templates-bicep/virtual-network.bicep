@description('The name of the arm vnet')
param armVnetName string

@description('CIDR for the address space of the ARM Vnet')
param armVnetAddressSpaceCIDR string

resource armVnet 'Microsoft.Network/virtualNetworks@2018-11-01' = {
  name: armVnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        armVnetAddressSpaceCIDR
      ]
    }
  }
}
