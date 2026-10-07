@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of service bus topic to create within the namespace')
param serviceBusTopicName string

@description('Names of service bus subscriptions to create within the topic')
param serviceBusSubscriptions array = []

var deploySubscriptions = (length(serviceBusSubscriptions) > 0)

resource serviceBusNamespaceName_serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' = {
  name: '${serviceBusNamespaceName}/${serviceBusTopicName}'
  properties: {}
}

resource serviceBusNamespaceName_deploySubscriptions_serviceBusTopicName_serviceBusSubscriptions_placeholder_placeholder 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2017-04-01' = [
  for i in range(0, (deploySubscriptions ? length(serviceBusSubscriptions) : 1)): if (deploySubscriptions) {
    name: '${serviceBusNamespaceName}/${(deploySubscriptions?'${serviceBusTopicName}/${serviceBusSubscriptions[i]}':'placeholder/placeholder')}'
    properties: {}
    dependsOn: [
      serviceBusNamespaceName_serviceBusTopic
    ]
  }
]
