@description('Name of the existing Event Grid custom topic to subscribe to. The topic must already exist in the resource group this template is deployed into.')
param topicName string

@description('Name of the event subscription to create on the topic.')
param eventSubscriptionName string

@description('Name of the Function App that hosts the event handler.')
param functionAppName string

@description('Name of the function (within the Function App) that handles the events. The function must be deployed before this subscription is created.')
param functionName string

@description('Resource group containing the Function App.')
param functionResourceGroup string

@description('Subscription ID containing the Function App. Defaults to the current subscription.')
param functionSubscriptionId string = subscription().subscriptionId

@description('Event types this subscription listens for (for example ["Microsoft.Security.MalwareScanningResult"]).')
param includedEventTypes array

@description('Maximum number of events to deliver per batch to the Azure Function.')
param maxEventsPerBatch int = 1

@description('Preferred batch size in kilobytes.')
param preferredBatchSizeInKilobytes int = 64

@description('Maximum number of delivery retry attempts before an event is dead-lettered or dropped.')
param maxDeliveryAttempts int = 30

@description('Time-to-live for events in minutes before they are dropped or dead-lettered.')
param eventTimeToLiveInMinutes int = 1440

@description('Delivery schema for events. Must match what the handler expects (EventGridTrigger functions expect EventGridSchema).')
param eventDeliverySchema string = 'EventGridSchema'

@description('Whether to enable dead-lettering of undelivered events to a storage blob container.')
param enableDeadLettering bool = false

@description('Resource ID of the storage account used for dead-lettering. Required when enableDeadLettering is true.')
param deadLetterStorageAccountResourceId string = ''

@description('Name of the blob container used for dead-lettered events.')
param deadLetterContainerName string = 'eventgrid-deadletter'

var subscriptionPropertiesBase = {
  destination: {
    endpointType: 'AzureFunction'
    properties: {
      resourceId: resourceId(
        functionSubscriptionId,
        functionResourceGroup,
        'Microsoft.Web/sites/functions',
        functionAppName,
        functionName
      )
      maxEventsPerBatch: maxEventsPerBatch
      preferredBatchSizeInKilobytes: preferredBatchSizeInKilobytes
    }
  }
  filter: {
    includedEventTypes: includedEventTypes
  }
  eventDeliverySchema: eventDeliverySchema
  retryPolicy: {
    maxDeliveryAttempts: maxDeliveryAttempts
    eventTimeToLiveInMinutes: eventTimeToLiveInMinutes
  }
}
var deadLetterDestination = {
  endpointType: 'StorageBlob'
  properties: {
    resourceId: deadLetterStorageAccountResourceId
    blobContainerName: deadLetterContainerName
  }
}
var subscriptionPropertiesWithDeadLetter = union(subscriptionPropertiesBase, {
  deadLetterDestination: deadLetterDestination
})

resource topicName_eventSubscription 'Microsoft.EventGrid/topics/eventSubscriptions@2022-06-15' = {
  name: '${topicName}/${eventSubscriptionName}'
  properties: (enableDeadLettering ? subscriptionPropertiesWithDeadLetter : subscriptionPropertiesBase)
}

output eventSubscriptionName string = eventSubscriptionName
