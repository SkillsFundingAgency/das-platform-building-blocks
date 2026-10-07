@description('Private DNS Zone name as per: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration')
param dnsZoneName string

@description('Optional - ResourceId of the Virtual Network to link with the Private DNS Zone')
param vnetId string = ''

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
  tags: {}
}

resource dnsZoneName_privatednslink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (length(vnetId) > 0) {
  parent: dnsZone
  name: 'privatednslink'
  location: 'global'
  tags: {}
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
