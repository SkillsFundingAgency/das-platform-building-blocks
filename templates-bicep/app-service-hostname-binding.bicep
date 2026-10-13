param customHostname string
param appServiceName string
param certificateThumbprint string
param sslState string = 'SniEnabled'

resource appServiceName_customHostname 'Microsoft.Web/sites/hostnameBindings@2022-09-01' = {
  name: '${appServiceName}/${customHostname}'
  location: resourceGroup().location
  properties: {
    sslState: sslState
    thumbprint: certificateThumbprint
  }
}
