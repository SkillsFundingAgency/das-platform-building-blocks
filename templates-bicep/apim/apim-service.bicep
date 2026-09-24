param apimName string
param apimInitialDeploy bool

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
param virtualNetworkResourceGroup string = ''
param virtualNetworkName string = ''
param subnetName string = ''
param keyVaultName string = ''
param keyVaultResourceGroup string = ''
param portalHostname string = ''
param portalKeyVaultCertificateName string = ''
param gatewayHostname string = ''
param gatewayKeyVaultCertificateName string = ''
param secureGatewayHostname string = ''
param secureGatewayKeyVaultCertificateName string = ''
param managementHostname string = ''
param managementKeyVaultCertificateName string = ''
param tenantId string
param apimAppRegistrationClientId string

@secure()
param apimAppRegistrationClientSecret string

var deploymentUrlBase = 'https://raw.githubusercontent.com/SkillsFundingAgency/das-platform-building-blocks/master/templates/'
var deployCustomHostnames = ((length(portalKeyVaultCertificateName) > 0) && (length(gatewayKeyVaultCertificateName) > 0))
var deployToNetwork = ((length(virtualNetworkName) > 0) && (virtualNetworkType != 'None'))
var subnetResourceId = '${resourceId(virtualNetworkResourceGroup,'Microsoft.Network/virtualNetworks',virtualNetworkName)}/subnets/${subnetName}'
var vnetConfiguration = {
  subnetResourceId: subnetResourceId
}

resource apim 'Microsoft.ApiManagement/service@2019-12-01' = if (apimInitialDeploy) {
  name: apimName
  location: resourceGroup().location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: (deployToNetwork ? vnetConfiguration : json('null'))
    virtualNetworkType: virtualNetworkType
  }
  identity: {
    type: 'SystemAssigned'
  }
}

module apimName_with_hostname_configurations './apim-service-with-hostnames.bicep' = if (deployCustomHostnames && (!apimInitialDeploy)) {
  name: '${apimName}-with-hostname-configurations'
  params: {
    apimName: apimName
    publisherEmail: publisherEmail
    publisherName: publisherName
    sku: sku
    skuCount: skuCount
    portalHostname: portalHostname
    portalKeyVaultSecretId: (deployCustomHostnames
      ? reference(
          resourceId(
            keyVaultResourceGroup,
            'Microsoft.KeyVault/vaults/secrets',
            keyVaultName,
            portalKeyVaultCertificateName
          ),
          '2018-02-14'
        ).secretUri
      : json('null'))
    gatewayHostname: gatewayHostname
    gatewayKeyVaultSecretId: (deployCustomHostnames
      ? reference(
          resourceId(
            keyVaultResourceGroup,
            'Microsoft.KeyVault/vaults/secrets',
            keyVaultName,
            gatewayKeyVaultCertificateName
          ),
          '2018-02-14'
        ).secretUri
      : json('null'))
    secureGatewayHostname: secureGatewayHostname
    secureGatewayKeyVaultSecretId: (deployCustomHostnames
      ? reference(
          resourceId(
            keyVaultResourceGroup,
            'Microsoft.KeyVault/vaults/secrets',
            keyVaultName,
            secureGatewayKeyVaultCertificateName
          ),
          '2018-02-14'
        ).secretUri
      : json('null'))
    managementHostname: managementHostname
    managementKeyVaultSecretId: (deployCustomHostnames
      ? reference(
          resourceId(
            keyVaultResourceGroup,
            'Microsoft.KeyVault/vaults/secrets',
            keyVaultName,
            managementKeyVaultCertificateName
          ),
          '2018-02-14'
        ).secretUri
      : json('null'))
    virtualNetworkType: virtualNetworkType
    subnetResourceId: subnetResourceId
    tenantId: tenantId
    apimAppRegistrationClientId: apimAppRegistrationClientId
    apimAppRegistrationClientSecret: apimAppRegistrationClientSecret
  }
}

output managedServiceIdentityId string = reference(apimName, '2019-12-01', 'Full').identity.principalId
