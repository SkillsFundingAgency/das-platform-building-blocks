param principalId string

@allowed([
  'AiSearchIndexReader'
  'AiSearchIndexContributor'
])
param assignmentType string
param resourceName string

var AiSearchIndexReader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/985c0cb4-34a0-4b8d-8a10-eb48105c3ba0'
var AiSearchIndexContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/3361dc54-610a-4045-99fe-6879e51ef62d'

resource resourceName_Microsoft_Authorization_principalId_resourceName_assignmentType_AiSearchIndexReader_AiSearchIndexReader_AiSearchIndexContributor 'Microsoft.Search/searchServices/providers/roleAssignments@2021-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId,resourceName,last(split(((assignmentType=='AiSearchIndexReader')?AiSearchIndexReader:AiSearchIndexContributor),'/'))))}'
  properties: {
    roleDefinitionId: ((assignmentType == 'AiSearchIndexReader') ? AiSearchIndexReader : AiSearchIndexContributor)
    principalId: principalId
  }
}
