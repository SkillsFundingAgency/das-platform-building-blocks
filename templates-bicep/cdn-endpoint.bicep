@description('Name of Content Delivery Network profile')
param cdnProfileName string

@description('Name of the endpoint has to be unique')
param cdnEndPointName string
param originHostName string

@allowed([
  'GeneralWebDelivery'
  'GeneralMediaStreaming'
  'VideoOnDemandMediaStreaming'
  'LargeFileDownload'
  'DynamicSiteAcceleration'
])
param optimizationType string = 'GeneralWebDelivery'
param customDomainName string = ''
param isHttpAllowed bool = false

@allowed([
  'NotSet'
  'IgnoreQueryString'
  'UseQueryString'
  'BypassCaching'
])
param queryStringCachingBehavior string = 'IgnoreQueryString'
param originPath string = ''

var fullEndpointName = '${cdnProfileName}/${cdnEndPointName}'
var customDomainEnabled = (length(customDomainName) > 0)
var originHostName_var = replace(replace(originHostName, 'https://', ''), '/', '')
var originPathProperties = {
  originPath: originPath
}
var cdnEndpointBaseProperties = {
  originHostHeader: originHostName_var
  contentTypesToCompress: [
    'text/plain'
    'text/html'
    'text/css'
    'text/javascript'
    'application/x-javascript'
    'application/javascript'
    'application/json'
    'application/xml'
  ]
  isCompressionEnabled: true
  isHttpAllowed: isHttpAllowed
  isHttpsAllowed: true
  queryStringCachingBehavior: queryStringCachingBehavior
  optimizationType: optimizationType
  origins: [
    {
      name: replace(originHostName, '.', '-')
      properties: {
        hostName: originHostName_var
        httpPort: 80
        httpsPort: 443
      }
    }
  ]
}
var cdnEndpointPropertiesWithOriginPath = union(cdnEndpointBaseProperties, originPathProperties)
var cdnEndpointProperties = ((originPath == '') ? cdnEndpointBaseProperties : cdnEndpointPropertiesWithOriginPath)

resource fullEndpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  name: fullEndpointName
  location: resourceGroup().location
  properties: cdnEndpointProperties
}

resource fullEndpointName_customDomainEnabled_customDomainName_placeholder 'Microsoft.Cdn/profiles/endpoints/customDomains@2021-06-01' = if (customDomainEnabled) {
  parent: fullEndpoint
  name: '${(customDomainEnabled?replace(customDomainName,'.','-'):'placeholder')}'
  properties: {
    hostName: customDomainName
  }
}

output endpointHostName string = reference(cdnEndPointName).hostname
