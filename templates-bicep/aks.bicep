@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The version of Kubernetes.')
param kubernetesVersion string
param servicePrincipalClientId string = ''

@secure()
param servicePrincipalSecret string = ''

@description('The ID of the separately created client app service principal, ignored if adminGroupObjectId is set')
param rbacClientAppId string = ''

@description('The ID of the separately created server app service principal, ignored if adminGroupObjectId is set')
param rbacServerAppId string = ''

@description('The secret of the separately created server app service principal, ignored if adminGroupObjectId is set')
@secure()
param rbacServerAppSecret string = ''

@description('The tenant ID of for legacy AAD integration, ignored if adminGroupObjectId is set')
param rbacTenantId string = ''
param serviceCidr string
param dnsServiceIp string
param podCidr string = '10.244.0.0/16'
param dockerBridgeCidr string = '172.17.0.1/16'

@description('The name of the default agent pool')
param agentPoolName string = 'agentpool'

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentNodeCount int = 3

@description('The sku of the machines that will be used for the default agentpool.')
param agentVMSize string = 'Standard_DS2_v2'

@description('Subnet name that will contain the aks CLUSTER')
param subnetName string

@description('Name of an existing VNET that will contain this AKS deployment.')
param virtualNetworkName string

@description('Name of the existing VNET resource group')
param virtualNetworkResourceGroup string = resourceGroup().name

@description('The name of the resource group for log analytics')
param logAnalyticsResourceGroupName string = resourceGroup().name

@description('The name of the log analytics workspace that will be used for monitoring')
param logAnalyticsWorkspaceName string

@description('The name of the resource group used for nodes')
param nodeResourceGroup string

@description('adminUsername and adminPassword for Windows nodes, if windowsProfile not required pass in an empty object \'{}\'')
@secure()
param windowsProfile object

@description('If specified then AKS-managed Azure AD will be configured and the group this Object ID represents will have admin rights over the cluster')
@metadata({ documentation: 'https://docs.microsoft.com/en-gb/azure/aks/managed-aad' })
param adminGroupObjectId string = ''
param legacyDeployment bool = true

@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string = 'kubenet'

@metadata({ documentation: 'https://docs.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges' })
param apiServerAuthorizedIPRanges array
param enableEncryptionAtHost bool = true

@description('Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node.')
param nodeMaxGracefulTerminationSec string = '3600'

@description('How long a node should be unneeded before it\'s eligible for scale down.')
param nodeScaleDownUnneededTime string = '60m'

@description('How often the cluster is reevaluated for scale up or down.')
param nodeScanInterval string = '10s'

var agentPoolProfile = {
  withMode: [
    {
      name: agentPoolName
      count: agentNodeCount
      vmSize: agentVMSize
      osType: 'Linux'
      mode: 'System'
      vnetSubnetID: vnetSubnetId
      type: 'VirtualMachineScaleSets'
      storageProfile: 'ManagedDisks'
      enableEncryptionAtHost: enableEncryptionAtHost
    }
  ]
  withoutMode: [
    {
      name: agentPoolName
      count: agentNodeCount
      vmSize: agentVMSize
      osType: 'Linux'
      vnetSubnetID: vnetSubnetId
      type: 'VirtualMachineScaleSets'
      storageProfile: 'ManagedDisks'
      enableEncryptionAtHost: enableEncryptionAtHost
    }
  ]
}
var aksBaseProperties = {
  kubernetesVersion: kubernetesVersion
  dnsPrefix: clusterName
  agentPoolProfiles: (legacyDeployment ? agentPoolProfile.withoutMode : agentPoolProfile.withMode)
  addonProfiles: {
    azurepolicy: {
      enabled: true
    }
    omsagent: {
      enabled: true
      config: {
        logAnalyticsWorkspaceResourceID: logAnalyticsId
      }
    }
  }
  nodeResourceGroup: nodeResourceGroup
  enableRBAC: true
  aadProfile: (empty(adminGroupObjectId) ? aadProfile.configured : aadProfile.managed)
  networkProfile: {
    networkPlugin: networkPlugin
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIp
    podCidr: podCidr
    dockerBridgeCidr: dockerBridgeCidr
  }
  apiServerAccessProfile: {
    authorizedIPRanges: apiServerAuthorizedIPRanges
    enablePrivateCluster: false
  }
  workloadAutoScalerProfile: {
    keda: {
      enabled: true
    }
  }
  autoScalerProfile: {
    'max-graceful-termination-sec': nodeMaxGracefulTerminationSec
    'scale-down-unneeded-time': nodeScaleDownUnneededTime
    'scan-interval': nodeScanInterval
  }
}
var aadProfile = {
  configured: {
    clientAppID: rbacClientAppId
    serverAppID: rbacServerAppId
    serverAppSecret: rbacServerAppSecret
    tenantID: rbacTenantId
  }
  managed: {
    managed: true
    adminGroupObjectIDs: array(adminGroupObjectId)
  }
}
var emptyObject = {}
var logAnalyticsId = resourceId(
  logAnalyticsResourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspaceName
)
var servicePrincipalProfile = {
  servicePrincipalProfile: {
    clientId: servicePrincipalClientId
    secret: servicePrincipalSecret
  }
}
var vnetSubnetId = resourceId(
  virtualNetworkResourceGroup,
  'Microsoft.Network/virtualNetworks/subnets',
  virtualNetworkName,
  subnetName
)
var windowsProfile_var = {
  windowsProfile: windowsProfile
}
var servicePrincipalProperties = (empty(servicePrincipalClientId) ? emptyObject : servicePrincipalProfile)
var windowsProfileProperties = (empty(windowsProfile) ? emptyObject : windowsProfile_var)
var aksProperties = union(aksBaseProperties, servicePrincipalProperties, windowsProfileProperties)

resource clusterLegacy 'Microsoft.ContainerService/managedClusters@2019-08-01' = if (legacyDeployment) {
  location: resourceGroup().location
  name: clusterName
  identity: {
    type: (empty(servicePrincipalClientId) ? 'SystemAssigned' : 'None')
  }
  properties: aksProperties
}

resource cluster 'Microsoft.ContainerService/managedClusters@2022-11-01' = if (!legacyDeployment) {
  location: resourceGroup().location
  name: clusterName
  identity: {
    type: (empty(servicePrincipalClientId) ? 'SystemAssigned' : 'None')
  }
  properties: aksProperties
}

resource clusterName_Microsoft_Insights_service 'Microsoft.ContainerService/managedClusters/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${clusterName}/Microsoft.Insights/service'
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
  dependsOn: [
    clusterLegacy
    cluster
  ]
}
