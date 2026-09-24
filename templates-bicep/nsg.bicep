param nsgName string
param securityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: nsgName
  location: resourceGroup().location
  properties: {
    securityRules: securityRules
  }
}
