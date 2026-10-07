param apimName string
param tenantId string = ''
param aadGroupObjectId string = ''
param groupDisplayName string
param groupDescription string

var isExternal = ((length(tenantId) > 0) && (length(aadGroupObjectId) > 0))

resource apimName_isExternal_aadGroupObjectId_groupDisplay 'Microsoft.ApiManagement/service/groups@2019-12-01' = {
  name: '${apimName}/${(isExternal?aadGroupObjectId:groupDisplayName)}'
  properties: {
    displayName: groupDisplayName
    description: groupDescription
    type: (isExternal ? 'external' : 'custom')
    externalId: (isExternal ? 'aad://${tenantId}/groups/${aadGroupObjectId}' : json('null'))
  }
}
