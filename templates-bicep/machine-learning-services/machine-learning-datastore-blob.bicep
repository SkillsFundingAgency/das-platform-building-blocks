param datastoreName string
param blobContainerName string
param storageAccountName string
param workspaceName string

resource workspaceName_datastore 'Microsoft.MachineLearningServices/workspaces/datastores@2021-03-01-preview' = {
  name: '${workspaceName}/${datastoreName}'
  properties: {
    contents: {
      contentsType: 'AzureBlob'
      accountName: storageAccountName
      containerName: blobContainerName
      endpoint: 'core.windows.net'
      protocol: 'https'
      credentials: {
        credentialsType: 'None'
      }
    }
    properties: {
      ServiceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
    }
  }
}
