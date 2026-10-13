param apimName string
param policyFragmentName string
param policyFragmentDescription string = ''

@allowed([
  'rawxml'
  'xml'
])
param policyFragmentFormat string = 'rawxml'
param policyFragmentContent string

resource apimName_policyFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: '${apimName}/${policyFragmentName}'
  properties: {
    description: policyFragmentDescription
    format: policyFragmentFormat
    value: policyFragmentContent
  }
}
