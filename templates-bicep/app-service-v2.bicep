param appServiceName string
param appServicePlanName string
param appServicePlanResourceGroup string

@secure()
param appServiceAppSettings object = {
  array: []
}

@secure()
param appServiceConnectionStrings object = {
  array: []
}
param appServiceVirtualApplications array = [
  {
    virtualPath: '/'
    physicalPath: 'site\\wwwroot'
    preloadEnabled: true
    virtualDirectories: null
  }
]
param customHostName string = ''

@description('This can be passed into the template via the reference function: [reference(resourceId(parameters(\'certificateResourceGroup\'), \'Microsoft.Web/certificates\', parameters(\'certificateName\')), \'2016-03-01\').Thumbprint]')
param certificateThumbprint string = ''
param deployStagingSlot bool = true

@description('Format removing backlashes: [{"Name": "IP A","ipAddress": "123.123.123.123"},{"Name": "IP B","ipAddress": "234.234.234.234"}]')
param ipSecurityRestrictions array = []

@description('Specify the minimum TLS cipher suite to enforce for the App Service. Use this when you need stricter security requirements than the default.')
param minTlsCipherSuite string = 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'

@description('Use if any settings will be different between production and staging slots. Specify in the name of the setting in the SlotSetting parameters')
@secure()
param appServiceSlotAppSettings object = {
  array: []
}

@description('List of app settings to set as slot specific: ["EnvironmentName", "ReadOnly"]')
param appServiceSlotSettingAppSettings array = [
  'WEBSITE_LOCAL_CACHE_OPTION'
  'WEBSITE_LOCAL_CACHE_SIZEINMB'
]

@description('Use if any settings will be different between production and staging slots. Specify in the name of the setting in the SlotSetting parameters')
@secure()
param appServiceSlotConnectionStrings object = {
  array: []
}

@description('The path for the health check endpoint. Leave empty to disable health check.')
param healthCheckPath string = ''

@description('List of connection strings to set as slot specific: ["Sql", "CosmosDb", "Redis"]')
param appServiceSlotSettingConnectionStrings array = []

@allowed([
  'web'
  'app'
  'api'
])
param appKind string = 'app'

@description('Resource ID of the subnet used for vNet integration')
param subnetResourceId string = ''

@description('This causes all outbound traffic to route through the Virtual Network. Virtual Network Security Groups and User Defined Routes will also be applied when enabled')
param vnetRouteAllEnabled bool = false

var appServiceProductionSlotAppSettings = [
  {
    name: 'WEBSITE_LOCAL_CACHE_OPTION'
    value: 'Always'
  }
  {
    name: 'WEBSITE_LOCAL_CACHE_SIZEINMB'
    value: '1000'
  }
  {
    name: 'WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG'
    value: 1
  }
]
var appServiceStagingSlotAppSettings = [
  {
    name: 'WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG'
    value: 1
  }
]
var useCustomHostname = (length(customHostName) > 0)
var appServicePlanId = resourceId(appServicePlanResourceGroup, 'Microsoft.Web/serverfarms', appServicePlanName)
var useAppServiceSlotAppSettings = (length(appServiceSlotAppSettings.array) > 0)
var useAppServiceSlotConnectionStrings = (length(appServiceSlotConnectionStrings.array) > 0)
var useAppServiceStagingSlotAppSettingsCombined = union(
  appServiceSlotAppSettings.array,
  appServiceStagingSlotAppSettings
)
var appServiceApiVersion = '2023-12-01'
var appServiceProductionSlotAppSettingsCombined = union(
  appServiceAppSettings.array,
  appServiceProductionSlotAppSettings
)
var appServiceStagingSlotAppSettingsCombined = union(appServiceAppSettings.array, appServiceStagingSlotAppSettings)

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  kind: appKind
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    clientAffinityEnabled: false
    siteConfig: {
      alwaysOn: true
      appSettings: appServiceProductionSlotAppSettingsCombined
      connectionStrings: appServiceConnectionStrings.array
      virtualApplications: appServiceVirtualApplications
      ipSecurityRestrictions: ipSecurityRestrictions
      minTlsVersion: '1.2'
      minTlsCipherSuite: minTlsCipherSuite
      ftpsState: 'Disabled'
      healthCheckPath: healthCheckPath
    }
    httpsOnly: true
    vnetRouteAllEnabled: vnetRouteAllEnabled
    outboundVnetRouting: {
      allTraffic: vnetRouteAllEnabled
    }
  }
}

resource appServiceName_staging 'Microsoft.Web/sites/slots@2023-12-01' = if (deployStagingSlot) {
  parent: appService
  name: 'staging'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    clientAffinityEnabled: false
    siteConfig: {
      appSettings: (useAppServiceSlotAppSettings
        ? useAppServiceStagingSlotAppSettingsCombined
        : appServiceStagingSlotAppSettingsCombined)
      connectionStrings: (useAppServiceSlotConnectionStrings
        ? appServiceSlotConnectionStrings.array
        : appServiceConnectionStrings.array)
      virtualApplications: appServiceVirtualApplications
      ipSecurityRestrictions: ipSecurityRestrictions
      minTlsVersion: '1.2'
      minTlsCipherSuite: minTlsCipherSuite
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
}

resource appServiceName_slotconfignames 'Microsoft.Web/sites/config@2018-11-01' = if (deployStagingSlot) {
  parent: appService
  name: 'slotConfigNames'
  properties: {
    appSettingNames: appServiceSlotSettingAppSettings
    connectionStringNames: appServiceSlotSettingConnectionStrings
  }
}

resource appServiceName_useCustomHostname_customHostname_placeholder 'Microsoft.Web/sites/hostnameBindings@2018-11-01' = if (useCustomHostname) {
  parent: appService
  name: '${(useCustomHostname?customHostName:'placeholder')}'
  location: resourceGroup().location
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}

resource appServiceName_virtualNetwork 'Microsoft.Web/sites/config@2018-11-01' = if (length(subnetResourceId) > 0) {
  parent: appService
  name: 'virtualNetwork'
  location: resourceGroup().location
  properties: {
    subnetResourceId: subnetResourceId
    swiftSupported: true
  }
}

output possibleOutboundIpAddresses array = split(appService.properties.possibleOutboundIpAddresses, ',')
output managedServiceIdentityId string = reference(appServiceName, appServiceApiVersion, 'Full').identity.principalId
output stagingManagedServiceIdentityId string = reference('staging', appServiceApiVersion, 'Full').identity.principalId
