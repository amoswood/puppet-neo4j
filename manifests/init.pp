# Class: lw_neo4j
#
# This module manages lw_neo4j
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class lw_neo4j {

  group { 'neo4j': }

  user { 'neo4j':
    gid => 'neo4j',
  }

  File {
    owner=>'neo4j',
    group=>'neo4j',
    mode=>'0755'
  }

  file { '/opt/neo4j':
    ensure => directory,
  }

  file { '/opt/neo4j/data':
    ensure => directory,
  }

  file { '/opt/neo4j/neo4j-enterprise-2.0.3':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/lw_neo4j/neo4j-enterprise-2.0.3/',
  }

  #install the service
  file {'/etc/init.d/neo4j':
    ensure=>link,
    target=>'/opt/neo4j/neo4j-enterprise-2.0.3/bin/neo4j',
    require=>File['/opt/neo4j/neo4j-enterprise-2.0.3'],
  }

  # Track the configuration files
  file { '/opt/neo4j/neo4j-enterprise-2.0.3/conf/neo4j.properties':
    ensure  => present,
    source  => 'puppet:///modules/lw_neo4j/conf/neo4j.properties',
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
  file { '/opt/neo4j/neo4j-enterprise-2.0.3/conf/neo4j-server.properties':
    ensure  => present,
    source  => 'puppet:///modules/lw_neo4j/conf/neo4j-server.properties',
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
  file { '/opt/neo4j/neo4j-enterprise-2.0.3/conf/neo4j-wrapper.conf':
    ensure  => present,
    source  => 'puppet:///modules/lw_neo4j/conf/neo4j-wrapper.conf',
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  service{'neo4j':
    ensure=>running,
    enable=>true,
    require=>File['/etc/init.d/neo4j'],
  }
}
