param apimName string

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@allowed([
  '1'
  '2'
])
param skuCount string = '1'

@allowed([
  'None'
  'Internal'
  'External'
])
param virtualNetworkType string = 'None'
param subnetResourceId string = ''
param portalHostname string = ''
param portalKeyVaultSecretId string = ''
param gatewayHostname string = ''
param gatewayKeyVaultSecretId string = ''
param secureGatewayHostname string = ''
param secureGatewayKeyVaultSecretId string = ''
param managementHostname string = ''
param managementKeyVaultSecretId string = ''
param tenantId string
param apimAppRegistrationClientId string

@secure()
param apimAppRegistrationClientSecret string

var deployToNetwork = ((length(subnetResourceId) > 0) && (virtualNetworkType != 'None'))
var vnetConfiguration = {
  subnetResourceId: subnetResourceId
}

resource apim 'Microsoft.ApiManagement/service@2019-12-01' = {
  name: apimName
  location: resourceGroup().location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    hostnameConfigurations: [
      {
        type: 'DeveloperPortal'
        hostName: portalHostname
        keyVaultId: portalKeyVaultSecretId
        negotiateClientCertificate: false
      }
      {
        type: 'Proxy'
        hostName: gatewayHostname
        keyVaultId: gatewayKeyVaultSecretId
        negotiateClientCertificate: false
        defaultSslBinding: true
      }
      {
        type: 'Proxy'
        hostName: secureGatewayHostname
        keyVaultId: secureGatewayKeyVaultSecretId
        negotiateClientCertificate: false
      }
      {
        type: 'Management'
        hostName: managementHostname
        keyVaultId: managementKeyVaultSecretId
        negotiateClientCertificate: false
      }
    ]
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: (deployToNetwork ? vnetConfiguration : json('null'))
    virtualNetworkType: virtualNetworkType
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource apimName_Aad 'Microsoft.ApiManagement/service/identityProviders@2019-12-01' = {
  parent: apim
  name: 'Aad'
  properties: {
    type: 'aad'
    signinTenant: tenantId
    allowedTenants: [
      tenantId
    ]
    authority: 'login.windows.net'
    clientId: apimAppRegistrationClientId
    clientSecret: apimAppRegistrationClientSecret
  }
}
