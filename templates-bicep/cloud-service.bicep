@description('Name of the cloud service resource')
param cloudServiceName string

@description('PFX Certificate encoded as a string')
@secure()
param certificateData string = ''

@description('Thumbprint of the provided certificate')
param certificateThumbprint string = ''

@description('Thumbprint algorithm of the provided certificate')
param certificateThumbprintAlgorithm string = 'SHA1'

@description('Password for the provided certificate')
@secure()
param certificatePassword string = ''

var certificateValuesProvided = (((length(certificateData) > 0) && (length(certificateThumbprint) > 0)) && (length(certificatePassword) > 0))

resource cloudService 'Microsoft.ClassicCompute/domainNames@2017-11-01' = {
  name: cloudServiceName
  location: resourceGroup().location
  properties: {}
}

resource cloudServiceName_certificateThumbprintAlgorithm_certificateThumbprint 'Microsoft.ClassicCompute/domainNames/serviceCertificates@2016-11-01' = if (certificateValuesProvided) {
  parent: cloudService
  name: '${certificateThumbprintAlgorithm}-${certificateThumbprint}'
  properties: {
    thumbprintAlgorithm: certificateThumbprintAlgorithm
    thumbprint: certificateThumbprint
    data: certificateData
    certificateFormat: 'pfx'
    password: certificatePassword
  }
}
