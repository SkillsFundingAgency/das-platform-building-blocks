param principalId string

@allowed([
  'StorageBlobDataContributor'
  'StorageBlobDataReader'
  'StorageTableDataContributor'
  'StorageTableDataReader'
  'StorageQueueDataMessageProcessor'
  'StorageQueueDataMessageSender'
])
param assignmentType string
param resourceName string

var StorageBlobDataContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var StorageBlobDataReader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
var StorageTableDataContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
var StorageTableDataReader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/76199698-9eea-4c19-bc75-cec21354c6b6'
var StorageQueueDataMessageSender = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
var StorageQueueDataMessageProcessor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8a0f0c08-91a1-4084-bc3d-661d67233fed'

resource resourceName_Microsoft_Authorization_resourceName_assignmentType_principalId 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2021-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(resourceName,assignmentType,principalId))}'
  properties: {
    roleDefinitionId: ((assignmentType == 'StorageBlobDataContributor')
      ? StorageBlobDataContributor
      : ((assignmentType == 'StorageBlobDataReader')
          ? StorageBlobDataReader
          : ((assignmentType == 'StorageTableDataContributor')
              ? StorageTableDataContributor
              : ((assignmentType == 'StorageTableDataReader')
                  ? StorageTableDataReader
                  : ((assignmentType == 'StorageQueueDataMessageSender')
                      ? StorageQueueDataMessageSender
                      : StorageQueueDataMessageProcessor)))))
    principalId: principalId
    scope: resourceId('Microsoft.Storage/storageAccounts', resourceName)
  }
}
