param functionAppName string
param appServicePlanName string
param appServicePlanResourceGroup string

@secure()
param functionAppAppSettings object = {
  array: []
}

@secure()
param functionAppConnectionStrings object = {
  array: []
}
param customHostName string = ''

@description('This can be passed into the template via the reference function: [reference(resourceId(parameters(\'certificateResourceGroup\'), \'Microsoft.Web/certificates\', parameters(\'certificateName\')), \'2016-03-01\').Thumbprint]')
param certificateThumbprint string = ''

@description('Must use this format: https://docs.microsoft.com/en-us/azure/templates/microsoft.web/2016-08-01/sites#IpSecurityRestriction. 2018-02-01 API will break template using current WAFOutboundIPAddresses shared variable.')
param ipSecurityRestrictions array = []

@description('Resource ID of the subnet used for vNet integration')
param subnetResourceId string = ''

@description('Bool used to determine whether Runtime Scale Monitoring will be enabled for the given function app')
param runtimeScaleMonitoringEnabled bool = false

@description('.NET version of project, e.g. v6.0, needed for runtime version ~4 onwards')
@metadata({
  link: 'https://learn.microsoft.com/en-us/answers/questions/835272/azure-functions-pinned-to-unsupported-dotnet-runti.html'
})
@allowed([
  ''
  'v6.0'
  'v8.0'
  'v10.0'
])
param netFrameworkVersion string = ''

@description('This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied when enabled')
param vnetRouteAllEnabled bool = false

var useCustomHostname = (length(customHostName) > 0)
var appServicePlanId = resourceId(appServicePlanResourceGroup, 'Microsoft.Web/serverfarms', appServicePlanName)
var functionAppApiVersion = '2019-08-01'
var baseSiteConfig = {
  appSettings: functionAppAppSettings.array
  connectionStrings: functionAppConnectionStrings.array
  ipSecurityRestrictions: ipSecurityRestrictions
  functionsRuntimeScaleMonitoringEnabled: runtimeScaleMonitoringEnabled
  minTlsVersion: '1.2'
  ftpsState: 'Disabled'
}
var siteConfigNetFrameworkVersion = {
  netFrameworkVersion: netFrameworkVersion
}
var siteConfig = ((length(netFrameworkVersion) > 0)
  ? union(baseSiteConfig, siteConfigNetFrameworkVersion)
  : baseSiteConfig)

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName
  kind: 'functionapp'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    clientAffinityEnabled: false
    siteConfig: union(
      {
        alwaysOn: (contains(
            [
              'functionapp'
              'elastic'
            ],
            reference(
              resourceId(appServicePlanResourceGroup, 'Microsoft.Web/serverFarms', appServicePlanName),
              '2019-08-01'
            ).kind
          )
          ? 'false'
          : 'true')
      },
      siteConfig
    )
    httpsOnly: true
    vnetRouteAllEnabled: vnetRouteAllEnabled
  }
}

resource functionAppName_useCustomHostname_customHostname_placeholder 'Microsoft.Web/sites/hostnameBindings@2018-11-01' = if (useCustomHostname) {
  parent: functionApp
  name: '${(useCustomHostname?customHostName:'placeholder')}'
  location: resourceGroup().location
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}

resource functionAppName_virtualNetwork 'Microsoft.Web/sites/config@2018-11-01' = if (length(subnetResourceId) > 0) {
  parent: functionApp
  name: 'virtualNetwork'
  location: resourceGroup().location
  properties: {
    subnetResourceId: subnetResourceId
    swiftSupported: true
  }
}

output managedServiceIdentityId string = reference(functionAppName, functionAppApiVersion, 'Full').identity.principalId
