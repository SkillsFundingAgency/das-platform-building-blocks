@description('Name of the application insights resource')
param scopedResourceName string

@description('Name of the Private Link Scope')
param privateLinkScopeName string
param scopedResourceId string = ''

resource privateLinkScopeName_scopedResourceName_connection 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-09-01' = {
  name: '${privateLinkScopeName}/${scopedResourceName}-connection'
  properties: {
    linkedResourceId: scopedResourceId
  }
}
