param apimName string
param enabled bool

resource apimName_signup 'Microsoft.ApiManagement/service/portalsettings@2020-12-01' = {
  name: '${apimName}/signup'
  properties: {
    enabled: enabled
    termsOfService: {
      consentRequired: 'false'
      enabled: 'false'
      text: ''
    }
  }
}
