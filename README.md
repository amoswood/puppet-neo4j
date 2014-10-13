# neo4j puppet module

####Table of Contents

1. [Overview](#overview)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Reference](#reference)

## Overview

Installs Neo4J (http://www.neo4j.com) on Ubuntu/Debian from their distribution tarballs downloaded directly from their site.

##Setup

All of the setup for any of the configuration is done through via class `neo4j`.  There are default options
provided such that you can install Neo4j into `/opt/neo4j` and start listening on `http://your_ip:7474/` by specifying:

```puppet
include neo4j
```

To install enterprise edition 2.0.3, you can specify:

```puppet
class { 'neo4j' :
  version => '2.0.3',
  edition => 'enterprise',
}
```

See [usage](#usage) scenarios below for further usages.

##Usage

Currently, all of the configurations are done through the class `neo4j` including clustered Neo4j server.

Here are some example of different configurations that people could use this module to manage their Neo4j instances.

**Note:** *For an explain of parameters and a complete list, please see the [reference](#reference) section below.*

### Basic Install
```puppet
class { 'neo4j' :
}
```
### Different Version
All known versions >= 2.0.0 can be installed.  For the list of current releases, you can go to http://neo4j.com/download/.
```puppet
class { 'neo4j' :
  version => '2.0.3',
  edition => 'enterprise',
}
```
### Different Install Path

If you want to install to another directory, use the `install_prefix` parameter.
```puppet
class { 'neo4j' :
  install_prefix => '/tmp',
}
```
### Custom JVM Memory Options

```puppet
class { 'neo4j' :
  jvm_init_memory => '1024',
  jvm_max_memory  => '1024',
}
```
### Cache Options

The cache options can be customized too to allow for better performance scaling.  For an explanation and usage
of these options, see Neo4j documentation on [caching](http://docs.neo4j.org/chunked/stable/configuration-caches.html).
```puppet
class { 'neo4j' :
  nodestore_memory                  => '25M',
  relationshipstore_memory          => '50M',
  propertystore_memory              => '100M',
  propertystore_strings_memory      => '130M',
  propertystore_arrays_memory       => '130M',
  cache_type                        => 'hpc',
  cache_memory_ratio                => '50.0',
  node_cache_array_fraction         => '5',
  relationship_cache_array_fraction => '5',
  node_cache_size                   => '100M',
  relationship_cache_size           => '100M',
}
```
### Authentication and User Management
To force authentication of the data and management entry points, you can use the `auth_ensure` and include `auth_admin_user` and `auth_admin_password` parameters too.
The `auth_users` is optional, but can be used to manage authorized users.

```puppet
$auth_users = {
  user1 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => true,
  },
}

class { 'neo4j' :
  auth_ensure         => present,
  auth_admin_user     => 'admin',
  auth_admin_password => 'password',
  auth_users          => $auth_users, #optional
}
```
### New Relic Monitoring
You can also specify to monitor the server with New Relic. Sign-up and monitoring is free from http://www.newrelic.com.
```puppet
class { 'neo4j' :
  newrelic_jar_path => '/path/to/newrelic.jar',
}
```
##Reference

###neo4j
Manages the server.
####Attributes
- `version` -- The version of Neo4j to install.
**Default:** *2.1.2*
- `edition` -- The edition of Neo4j to install. Possibles: (*community*, *enterprise*).
**Default:** *community*
- `install_prefix` -- Where to install the software.
**Default:** */opt/neo4j*
- `allow_remote_connections` -- Whether to allow remote connections to Neo4j instead of only from localhost.
**Default:** *true*

######Custom Memory Attributes
- `jvm_init_memory`\* -- Initial memory size of the jvm. Equates to java option "-Xms=XXX". Specified in MBs.
**Default:** *1024*
- `jvm_max_memory`\* -- Maximum memory size of the jvm. Equates to java option "-Xmx=XXX". Specified in MBs.
**Default:** *1024*

######Custom Cache Attributes -- See Neo4j documentation on [caching](http://docs.neo4j.org/chunked/stable/configuration-caches.html)
- `nodestore_memory`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `relationshipstore_memory`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `propertystore_memory`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `propertystore_strings_memory`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `propertystore_arrays_memory`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `cache_type`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `cache_memory_ratio`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `node_cache_array_fraction`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `relationship_cache_array_fraction`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `node_cache_size`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*
- `relationship_cache_size`\* -- See Neo4j documentation.
**Default:** *Neo4j default value*

\* - see Max DeMarzi's Neo4j blog entry titled [Scaling-Up](http://maxdemarzi.com/2013/11/25/scaling-up/)

######Authentication Attributes
- `auth_ensure`\*\* -- Turns on/off authentication. Possibles: *present*, *absent*.
**Default:** *absent*
- `auth_admin_user` -- Admin user name. Must be specified when using authentication.
**Default:** *undef*
- `auth_admin_password` -- Admin password. Must be specified when using authentication.
**Default:** *undef*
- `auth_users` -- Hash of users, passwords, and roles that can access Neo4j when using authentication.
**Default:** *undef*

  Sample Input:
  ```puppet
  $auth_users = {
    username1 => {
      ensure     => present,   #optional, defaults to present
      password   => 'mypass',
      readWrite  => true,      #optional, defaults to true
    },
    username2 => {
      password   => 'mypass',
    },
    username3 => {
      ensure     => absent,
      password   => '',        #you must specify this when removing the user
    },
  }
  ```

######New Relic Parameters
- `newrelic_jar_path` -- Specifies the full path to the newrelic java agent jar file.
**Default:** *undef*

######HA Parameters
These parameters configure the [Neo4j HA options](http://docs.neo4j.org/chunked/stable/ha-configuration.html).
- `ha_ensure` -- Turns on/off ha features. Possibles: *present*, *absent*.
**Default:** *absent*
- `ha_server_id` -- Required. Unique server id in cluster. Must be an integer.
**Default:** *undef*
- `ha_initial_hosts` -- Required. Other hosts in the cluster.
**Default:** *undef*

  ```puppet
  $ha_initial_hosts = "${::ipaddress}:5001,other_ip:5001,another_ip:5001"
  ```

  ```puppet
  $ha_initial_hosts = "${::fqdn}:5001,host1.domain:5001,host2.domain:5001"
  ```

- `ha_cluster_port` -- Port to listen to cluster heartbeats and management communications.
**Default:** *5001*
- `ha_data_port` -- Port to send/receive cluster data on.
**Default:** *6001*
- `ha_pull_interval` -- Pull interval from master. Specified in seconds.
**Default:** *Neo4j default*
- `ha_tx_push_factor` -- Push factor to X slave servers. Specified as an integer.
**Default:** *Neo4j default*
- `ha_tx_push_strategy` -- Push strategy to slave servers.
**Default:** *Neo4j default*
- `ha_allow_init_cluster` -- Allow server to initialize a cluster if it cannot contact other hosts.
**Default:** *Neo4j default*
- `ha_slave_only` -- Server can only be a slave in the cluster.
**Default:** *Neo4j default*

######Logging Parameters
- `keep_logical_logs` -- Specifies the [logical logs property](http://docs.neo4j.org/chunked/stable/configuration-logical-logs.html).
**Default:** *'7 days'*
