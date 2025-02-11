@description('Name of the APIM instance to apply fragment')
param apimName string

@description('Name of the policy fragment')
param policyFragmentName string

@description('Description of the policy fragment')
param policyFragmentDescription string = ''

@description('Format of policy fragment')
@allowed(['xml', 'rawxml'])
param policyFragmentFormat string = 'rawxml'

@description('Content of the policy fragment')
param policyFragmentContent string

resource policyFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: '${apimName}/${policyFragmentName}'
  properties: {
    description: policyFragmentDescription
    format: policyFragmentFormat
    value: policyFragmentContent
  }
}
