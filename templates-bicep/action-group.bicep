@description('Unique name (within the Resource Group) for the Action group.')
param actionGroupName string

@description('Short name (maximum 12 characters) for the Action group.')
@maxLength(12)
param actionGroupShortName string

@description('An array of email addresses that alerts will be sent to')
param emailAddresses array = []

@description('Webhook receiver service Name.')
param webhookReceiverName string = ''

@description('Webhook receiver service URI.')
param webhookServiceUri string = ''
param enableActionGroup bool = true

var emailRecieversProperty = (empty(emailAddresses) ? emptyArray : emailRecieversArray)
var emptyArray = []
var webHookReceiverArray = [
  {
    name: webhookReceiverName
    serviceUri: webhookServiceUri
    useCommonAlertSchema: true
  }
]
var webHookReceiverProperty = (empty(webhookServiceUri) ? emptyArray : webHookReceiverArray)
var emailRecieversArray = [
  for (item, i) in emailAddresses: {
    name: 'Email-${actionGroupName}-${i}'
    emailAddress: item
    useCommonAlertSchema: false
  }
]

resource actionGroup 'Microsoft.Insights/actionGroups@2018-03-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: enableActionGroup
    smsReceivers: []
    emailReceivers: emailRecieversProperty
    webhookReceivers: webHookReceiverProperty
  }
}

output actionGroupResourceId string = actionGroup.id
