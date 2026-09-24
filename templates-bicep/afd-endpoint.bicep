@description('Name of the Azure Front Door profile')
param afdProfileName string

@description('Name of the Azure Front Door endpoint')
param afdEndPointName string

@description('The host name of the origin. Must be a domain name.')
param originHostName string

@description('The path to the origin.')
param originPath string = ''

@description('The custom domain name.')
param customDomainName string = ''

@description('The resource name for the custom domain. If not provided, will be derived from customDomainName.')
param customDomainResourceName string = ''

@description('The name of the origin group.')
param originGroupName string = 'default-origin-group'

@description('The name of the origin.')
param originName string = 'default-origin'

@description('The name of the route.')
param routeName string = 'default-route'

@description('Whether to enable use of this rule. Permitted values: \'Enabled\', \'Disabled\'')
@allowed([
  'Enabled'
  'Disabled'
])
param enabledState string = 'Enabled'

@description('Whether to automatically redirect HTTP traffic to HTTPS traffic. Permitted values: \'Enabled\', \'Disabled\'')
@allowed([
  'Enabled'
  'Disabled'
])
param httpsRedirect string = 'Enabled'

@description('Protocol this rule will use when forwarding traffic to backends. Permitted values: \'HttpOnly\', \'HttpsOnly\', \'MatchRequest\'')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param forwardingProtocol string = 'MatchRequest'

@description('Defines how the CDN caches requests that include query strings. You can ignore any query strings when caching, bypass caching to prevent requests that contain query strings from being cached, or cache every request with a unique URL. Permitted values: \'IgnoreQueryString\', \'UseQueryString\', \'NotSet\'')
@allowed([
  'IgnoreQueryString'
  'UseQueryString'
  'NotSet'
])
param queryStringCachingBehavior string = 'IgnoreQueryString'

@description('The path used for health probes against the origin. Defaults to \'/\' if not specified.')
param healthProbePath string = '/'

var originHostName_var = replace(replace(originHostName, 'https://', ''), '/', '')
var customDomainEnabled = (length(customDomainName) > 0)
var customDomainResourceName_var = ((length(customDomainResourceName) > 0)
  ? customDomainResourceName
  : ((length(customDomainName) > 0) ? replace(customDomainName, '.', '-') : 'placeholder-domain'))

resource afdProfileName_afdEndPoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: '${afdProfileName}/${afdEndPointName}'
  location: 'global'
  properties: {
    enabledState: enabledState
  }
}

resource afdProfileName_originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: '${afdProfileName}/${originGroupName}'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: healthProbePath
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource afdProfileName_originGroupName_origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: afdProfileName_originGroup
  name: originName
  properties: {
    hostName: originHostName_var
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName_var
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource afdProfileName_customDomainResource 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = if (customDomainEnabled) {
  name: '${afdProfileName}/${customDomainResourceName_var}'
  properties: {
    hostName: customDomainName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

resource afdProfileName_afdEndPointName_route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: afdProfileName_afdEndPoint
  name: routeName
  properties: {
    customDomains: (customDomainEnabled
      ? [
          {
            id: afdProfileName_customDomainResource.id
          }
        ]
      : [])
    originGroup: {
      id: afdProfileName_originGroup.id
    }
    originPath: (empty(originPath) ? null : originPath)
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    cacheConfiguration: {
      queryStringCachingBehavior: queryStringCachingBehavior
      compressionSettings: {
        isCompressionEnabled: true
        contentTypesToCompress: [
          'application/eot'
          'application/font'
          'application/font-sfnt'
          'application/javascript'
          'application/json'
          'application/opentype'
          'application/otf'
          'application/pkcs7-mime'
          'application/truetype'
          'application/ttf'
          'application/vnd.ms-fontobject'
          'application/xhtml+xml'
          'application/xml'
          'application/xml+rss'
          'application/x-font-opentype'
          'application/x-font-truetype'
          'application/x-font-ttf'
          'application/x-httpd-cgi'
          'application/x-javascript'
          'application/x-mpegurl'
          'application/x-opentype'
          'application/x-otf'
          'application/x-perl'
          'application/x-ttf'
          'font/eot'
          'font/ttf'
          'font/otf'
          'font/opentype'
          'image/svg+xml'
          'text/css'
          'text/csv'
          'text/html'
          'text/javascript'
          'text/js'
          'text/plain'
          'text/richtext'
          'text/tab-separated-values'
          'text/xml'
          'text/x-script'
          'text/x-component'
          'text/x-java-source'
        ]
      }
    }
    forwardingProtocol: forwardingProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: httpsRedirect
    enabledState: 'Enabled'
  }
  dependsOn: [
    afdProfileName_originGroupName_origin
  ]
}

output endpointHostName string = afdProfileName_afdEndPoint.properties.hostName
output endpointId string = afdProfileName_afdEndPoint.id
