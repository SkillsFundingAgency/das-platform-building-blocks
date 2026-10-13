param keyVaultName string

@description('Array of objects with the following schema: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/2018-02-14/vaults#AccessPolicyEntry')
param keyVaultAccessPolicies array = []
param enableRbacAuthorization bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false
param enableSoftDelete bool = true
param enableFirewall bool = false

@description('A list of subnet resource ids to whitelist on the Key Vault')
param subnetResourceIdList array = []

@description('A list of allowed IPs')
param allowedIpAddressesList array = []

@description('Allow trusted Microsoft services to bypass the firewall of the Key Vault')
param allowTrustedMicrosoftServices bool = true

@description('Log analytics workspace to send logs to (leave blank to disable)')
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

var virtualNetworkRulesArray = [
    for item in subnetResourceIdList: {
      id: item
      action: 'Allow'
    }
  ]
var virtualNetworkRules = {
  virtualNetworkRules: virtualNetworkRulesArray
}
var ipRulesArray = [
    for item in allowedIpAddressesList: {
      value: item
      action: 'Allow'
    }
  ]
var ipRules = {
  ipRules: ipRulesArray
}
var networkAclObject = {
  bypass: (allowTrustedMicrosoftServices ? 'AzureServices' : 'None')
  virtualNetworkRules: virtualNetworkRules.virtualNetworkRules
  ipRules: ipRules.ipRules
  defaultAction: (enableFirewall ? 'Deny' : 'Allow')
}
var logDiagnosticSettingsEnabled = (!empty(logAnalyticsWorkspaceName))
var logAnalyticsWorkspaceResourceId = resourceId(
  logAnalyticsWorkspaceResourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspaceName
)

resource keyVault 'Microsoft.KeyVault/vaults@2018-02-14' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    enableRbacAuthorization: enableRbacAuthorization
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: true
    enablePurgeProtection: true
    accessPolicies: keyVaultAccessPolicies
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: networkAclObject
  }
}

resource keyVaultName_Microsoft_Insights_service 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2021-05-01-preview' = if (logDiagnosticSettingsEnabled) {
  name: '${keyVaultName}/Microsoft.Insights/service'
  location: resourceGroup().location
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
  }
  dependsOn: [
    keyVault
  ]
}

output KeyVaultUri string = keyVault.properties.vaultUri
output KeyVaultResourceId string = keyVault.id
