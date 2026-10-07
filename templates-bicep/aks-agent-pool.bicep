@description('The name of an existing AKS cluster.')
param clusterName string

@description('The name of the agent pool to create or update.')
param agentPoolName string

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentNodeCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_DS2_v2'

@description('Subnet name that will contain the aks CLUSTER')
param subnetName string

@description('Name of an existing VNET that will contain this AKS deployment.')
param virtualNetworkName string

@description('Name of the existing VNET resource group')
param virtualNetworkResourceGroup string = resourceGroup().name

@description('The version of Kubernetes.')
param kubernetesVersion string

@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'
param nodeLabels object = {}
param nodeTaints array = []

@description('The maximum number of pods per node.')
@minValue(30)
@maxValue(250)
param maxPods int = 30

@description('Bool to enable node pool autoscaling.')
param enableNodeAutoScaling bool = false

@description('The minimum amount of nodes to autoscale down to.')
param minNodeAutoScalingCount int = -1

@description('The maximum amount of nodes to autoscale up to.')
param maxNodeAutoScalingCount int = -1

@description('The amount of time (in minutes) to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails.')
param nodeDrainTimeout int = 15

@description('Default of 0 will apply the default osDisk size according to the vmSize specified.')
param osDiskSizeGB int = 0
param enableEncryptionAtHost bool = true

var vnetSubnetId = resourceId(
  virtualNetworkResourceGroup,
  'Microsoft.Network/virtualNetworks/subnets',
  virtualNetworkName,
  subnetName
)
var baseProperties = {
  count: agentNodeCount
  vmSize: agentVMSize
  osType: osType
  osDiskSizeGB: osDiskSizeGB
  storageProfile: 'ManagedDisks'
  type: 'VirtualMachineScaleSets'
  vnetSubnetID: vnetSubnetId
  orchestratorVersion: kubernetesVersion
  nodeLabels: nodeLabels
  nodeTaints: nodeTaints
  maxPods: maxPods
  enableEncryptionAtHost: enableEncryptionAtHost
}
var withAutoscalingNodeProperties = {
  enableAutoScaling: true
  minCount: minNodeAutoScalingCount
  maxCount: maxNodeAutoScalingCount
  upgradeSettings: {
    drainTimeoutInMinutes: nodeDrainTimeout
  }
}
var agentPoolsProperties = (enableNodeAutoScaling
  ? union(baseProperties, withAutoscalingNodeProperties)
  : baseProperties)

resource clusterName_agentPool 'Microsoft.ContainerService/managedClusters/agentPools@2023-06-01' = {
  name: '${clusterName}/${agentPoolName}'
  location: resourceGroup().location
  properties: agentPoolsProperties
}
