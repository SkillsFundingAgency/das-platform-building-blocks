@description('Name of the Azure SQL Server  instance')
param sqlServerName string

param sqlServerLocation string = resourceGroup().location

@description('The Azure SQL Server Administrator (SA) username ')
param sqlServerAdminUserName string

@description('The Azure SQL Server Administrator (SA) password')
@secure()
param sqlServerAdminPassword string

@description('The active directory admin that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminLogin string

@description('The object id of the active directory admin that will be assigned to the SQL server')
param sqlServerActiveDirectoryAdminObjectId string

@description('This sets the Minimal TLS Version property for all SQL Database associated with the server. Any login attempts from clients using a TLS version less than the Minimal TLS Version shall be rejected.')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param sqlServerMinimalTlsVersion string

@description('The email address that threat alerts and vulnerability scans will be sent to')
param threatDetectionEmailAddress string

@description('Name of the SQL logs storage account for the environment')
param sqlStorageAccountName string

@description('The name of the OMS workspace that will collect audit events')
param logAnalyticsWorkspaceName string = ''

@description('The name of the OMS workspace resource group that will collect audit events')
param logAnalyticsWorkspaceResourceGroupName string = ''

@description('The id of the OMS workspace subscription that will collect audit events')
param logAnalyticsWorkspaceSubscriptionId string = ''

var auditPolicyName = 'Default'
var securityAlertPolicyName = 'Default'
var diagnosticSettingName = 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: sqlServerName
  location: sqlServerLocation
  properties: {
    administratorLogin: sqlServerAdminUserName
    administratorLoginPassword: sqlServerAdminPassword
    minimalTlsVersion: sqlServerMinimalTlsVersion
  }
}

resource sqlServerName_master 'Microsoft.Sql/servers/databases@2017-10-01-preview' = {
  parent: sqlServer
  location: sqlServerLocation
  name: 'master'
  properties: {}
}

resource sqlServerName_master_microsoft_insights_diagnosticSetting 'Microsoft.Sql/servers/databases/providers/diagnosticSettings@2017-05-01-preview' = if (length(logAnalyticsWorkspaceName) > 0) {
  name: '${sqlServerName}/master/microsoft.insights/${diagnosticSettingName}'
  properties: {
    name: diagnosticSettingName
    workspaceId: resourceId(
      logAnalyticsWorkspaceSubscriptionId,
      logAnalyticsWorkspaceResourceGroupName,
      'Microsoft.OperationalInsights/workspaces',
      logAnalyticsWorkspaceName
    )
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
  dependsOn: [
    sqlServerName_master
    sqlServer
  ]
}

resource sqlServerName_auditPolicy 'Microsoft.Sql/servers/auditingSettings@2017-03-01-preview' = {
  parent: sqlServer
  name: '${auditPolicyName}'
  properties: {
    state: 'Enabled'
    storageEndpoint: 'https://${sqlStorageAccountName}.blob.core.windows.net/'
    storageAccountAccessKey: listKeys(
      resourceId('Microsoft.Storage/storageAccounts', sqlStorageAccountName),
      providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]
    ).keys[0].value
    retentionDays: 365
    auditActionsAndGroups: [
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
    ]
    isAzureMonitorTargetEnabled: true
  }
}

resource sqlServerName_securityAlertPolicy 'Microsoft.Sql/servers/securityAlertPolicies@2017-03-01-preview' = {
  parent: sqlServer
  name: '${securityAlertPolicyName}'
  properties: {
    state: 'Enabled'
    emailAddresses: [
      threatDetectionEmailAddress
    ]
    emailAccountAdmins: false
    retentionDays: 90
  }
  dependsOn: [
    sqlServerName_auditPolicy
  ]
}

resource sqlServerName_activeDirectory 'Microsoft.Sql/servers/administrators@2014-04-01-preview' = {
  parent: sqlServer
  name: 'activeDirectory'
  location: sqlServerLocation
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlServerActiveDirectoryAdminLogin
    sid: sqlServerActiveDirectoryAdminObjectId
    tenantId: subscription().tenantId
  }
}

resource sqlServerName_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-02-01-preview' = {
  parent: sqlServer
  name: 'Default'
  properties: {
    recurringScans: {
      emails: [
        threatDetectionEmailAddress
      ]
      emailSubscriptionAdmins: false
      isEnabled: true
    }
    storageAccountAccessKey: listKeys(
      resourceId('Microsoft.Storage/storageAccounts', sqlStorageAccountName),
      providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]
    ).keys[0].value
    storageContainerPath: 'https://${sqlStorageAccountName}.blob.core.windows.net/vulnerability-assessment'
  }
  dependsOn: [
    sqlServerName_securityAlertPolicy
  ]
}
