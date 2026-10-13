param computeName string
param workspaceName string

@allowed([
  'AmlCompute'
])
param computeType string
param amlComputeSettings object = {
  maxNodeCount: 1
  minNodeCount: 0
  nodeIdleTimeBeforeScaleDown: 'PT300S'
  vmPriority: 'LowPriority'
  vmSize: 'Standard_D1_v2'
}

@description('Name of the resource group which holds the VNET to which you want to inject your compute in.')
param vnetResourceGroupName string

@description('Name of the vnet which you want to inject your compute in.')
param vnetName string

@description('Name of the subnet inside the VNET which you want to inject your compute in.')
param subnetName string

var subnet = {
  id: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
}

resource workspaceName_compute 'Microsoft.MachineLearningServices/workspaces/computes@2021-07-01' = if (computeType == 'AmlCompute') {
  name: '${workspaceName}/${computeName}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'AmlCompute'
    disableLocalAuth: true
    properties: {
      remoteLoginPortPublicAccess: 'NotSpecified'
      scaleSettings: {
        maxNodeCount: amlComputeSettings.maxNodeCount
        minNodeCount: amlComputeSettings.minNodeCount
        nodeIdleTimeBeforeScaleDown: amlComputeSettings.nodeIdleTimeBeforeScaleDown
      }
      vmPriority: amlComputeSettings.vmPriority
      vmSize: amlComputeSettings.vmSize
      subnet: subnet
    }
  }
}
