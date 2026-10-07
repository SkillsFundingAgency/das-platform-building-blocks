// ARM-backed compatibility module: native Bicep translation remains pending.
@description('Name of the application gateway resource')
param appGatewayName string

@description('back end pool ip addresses')
param backendPools array

@description('Http settings for access backend pools')
param backendHttpSettings array

param firewallPolicyName string

@description('routing rules')
param routingRules array

param subnetName string

@description('The name of the user assigned identity.')
param userAssignedIdentityName string

param virtualNetworkName string

param virtualNetworkResourceGroup string

@description('Application gateway tier')
@allowed(['Standard_v2', 'WAF_v2'])
param appGatewayTier string = 'Standard_v2'

@description('Number of instances of the app gateway running')
param capacity int = 2

@description('Probes to create')
param customProbes array = []

@description('Optionally set custom error pages')
param customErrorPages array = []

@description('Http frontend port.')
param httpFrontendPort int = 80

@description('Https frontend port.')
param httpsFrontendPort int = 443

@description('Log analytics workspace to send logs to (leave blank to disable)')
param logAnalyticsWorkspaceName string = ''

param logAnalyticsWorkspaceResourceGroupName string = ''

@description('Number of days to retain the log files for (set to 0 to disable retention policy)')
param logRetention int = 0

@description('Set the private IP address for application gateway (public IP address only generated if empty)')
param privateIpAddress string = ''

@description('Resource Id for a public IP address')
param publicIpAddressResourceId string = ''

@description('routing')
param rewriteRules array = []

param sslPolicy object = {policyType: 'Predefined', policyName: 'AppGwSslPolicy20170401S'}

module armTemplate '../templates/app-gateway-v2.json' = {
  name: 'app-gateway-v2'
  params: {
    appGatewayName: appGatewayName
    backendPools: backendPools
    backendHttpSettings: backendHttpSettings
    firewallPolicyName: firewallPolicyName
    routingRules: routingRules
    subnetName: subnetName
    userAssignedIdentityName: userAssignedIdentityName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    appGatewayTier: appGatewayTier
    capacity: capacity
    customProbes: customProbes
    customErrorPages: customErrorPages
    httpFrontendPort: httpFrontendPort
    httpsFrontendPort: httpsFrontendPort
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceResourceGroupName: logAnalyticsWorkspaceResourceGroupName
    logRetention: logRetention
    privateIpAddress: privateIpAddress
    publicIpAddressResourceId: publicIpAddressResourceId
    rewriteRules: rewriteRules
    sslPolicy: sslPolicy
  }
}
