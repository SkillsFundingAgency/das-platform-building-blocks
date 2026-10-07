param functionAppName string
param corsOrigins array = [
  'https://functions-next.azure.com'
  'https://functions-staging.azure.com'
  'https://functions.azure.com'
  'https://portal.azure.com'
]

resource functionAppName_web 'Microsoft.Web/sites/config@2020-10-01' = {
  name: '${functionAppName}/web'
  properties: {
    cors: {
      allowedOrigins: corsOrigins
    }
  }
}
