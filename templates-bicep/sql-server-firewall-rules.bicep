@description('The prefix for the firewall rule name, it will be appended by the IP address')
param firewallRuleNamePrefix string = ''

@description('Array of IP addresses to whitelist against a SQL server')
param ipAddresses array = []

@description('Name of the server to add firewall rules to')
param serverName string

@description('A list of subnet resource ids.')
param subnetResourceIdList array = []

resource serverName_firewallRuleNamePrefix_0_ipAddresses_placeholder 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = [
  for i in range(0, ((length(ipAddresses) > 0) ? length(ipAddresses) : 1)): if (length(ipAddresses) > 0) {
    name: '${serverName}/${((length(firewallRuleNamePrefix)>0)?ipAddresses[i]:'placeholder')}'
    properties: {
      startIpAddress: ipAddresses[i]
      endIpAddress: ipAddresses[i]
    }
  }
]

resource serverName_subnetResourceIdList_0_subnetResourceIdList_placeholder 'Microsoft.Sql/servers/virtualNetworkRules@2015-05-01-preview' = [
  for i in range(0, ((length(subnetResourceIdList) > 0) ? length(subnetResourceIdList) : 1)): if (length(subnetResourceIdList) > 0) {
    name: '${serverName}/${((length(subnetResourceIdList)>0)?last(split(subnetResourceIdList[i],'/')):'placeholder')}'
    properties: {
      virtualNetworkSubnetId: subnetResourceIdList[i]
    }
  }
]
