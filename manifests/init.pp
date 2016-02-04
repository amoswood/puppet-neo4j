# == Class: neo4j
#
# Installs Neo4J (http://www.neo4j.com) on RHEL/Ubuntu/Debian from their
# distribution tarballs downloaded directly from their site.
#
# === Parameters
#
# See Readme.md
#
# === Examples
#
#  class { 'neo4j' :
#    version => '2.0.3',
#    edition => 'enterprise',
#  }
#
# See additional examples in the Readme.md file.
#
# === Authors
#
# Amos Wood <amosjwood@gmail.com>
#
# === Copyright
#
# Copyright 2014 Amos Wood, unless otherwise noted.
#
class neo4j (
  $version = '2.1.2',
  $edition = 'community',
  $install_prefix = '/opt/neo4j',

  #service options
  $service_ensure = running,
  $service_enable = true,

  #server options
  $allow_remote_connections = true,
  $address = $::ipaddress,
  $jvm_init_memory = '1024',
  $jvm_max_memory = '1024',

  # file buffer cache options
  $nodestore_memory = undef,
  $relationshipstore_memory = undef,
  $propertystore_memory = undef,
  $propertystore_strings_memory = undef,
  $propertystore_arrays_memory = undef,

  # object cache options
  $cache_type = undef,
  $cache_memory_ratio = undef,  # available starting in 2.1.5
  $node_cache_array_fraction = undef,
  $relationship_cache_array_fraction = undef,
  $node_cache_size = undef,
  $relationship_cache_size = undef,

  #security
  $auth_ensure = absent,
  $auth_admin_user = undef,
  $auth_admin_password = undef,
  $auth_users = undef,

  #newrelic
  $newrelic_jar_path = undef,

  #high availability settings
  $ha_ensure = absent,
  $ha_server_id = undef,
  $ha_cluster_port = '5001',
  $ha_data_port = '6001',
  $ha_pull_interval = undef,
  $ha_tx_push_factor = undef,
  $ha_tx_push_strategy = undef,
  $ha_allow_init_cluster = true,
  $ha_slave_only = false,

  #logging options
  $keep_logical_logs = '7 days',
)
{
  #http://www.neo4j.com/customer/download/neo4j-enterprise-2.1.4-unix.tar.gz
  $package_name = "neo4j-${edition}-${version}"
  $package_tarball = "${package_name}.tgz"

  if($::kernel != 'Linux') {
    fail('Only Linux is supported at this time.')
  }
  if(versioncmp($version, '2.0.0') < 0) {
    fail('Only versions >= 2.0.0 are supported at this time.')
  }
  if($ha_ensure != absent) {
    if(!is_numeric($ha_server_id)) {
      fail('The Server Id value must be specified and must numeric.')
    }
  }

  if($cache_memory_ratio) {
    if(versioncmp($version, '2.1.5') < 0) {
      warning("Ignoring the cache_memory_ratio value due to version being '${version}'.")
    }
    elsif(!is_numeric($cache_memory_ratio) or $cache_memory_ratio < 0.0 or
      $cache_memory_ratio > 100.0) {
        fail("Invalid cache_memory_ratio value of '${cache_memory_ratio}'. It must be in the range of 0.0 to 100.0.")
    }
  }

  user { 'neo4j':
    ensure => present,
    gid    => 'neo4j',
    shell  => '/bin/bash',
    home   => $install_prefix,
  }
  group { 'neo4j':
    ensure=>present,
  }

  File {
    owner => 'neo4j',
    group => 'neo4j',
    mode  => '0644',
  }

  Exec {
    path => ['/usr/bin', '/usr/local/bin', '/bin', '/sbin'],
  }

  contain neo4j::install
  contain neo4j::config
  if ( $auth_ensure == present ) {
    contain neo4j::authentication
  }
  contain neo4j::service

  Class['neo4j::install'] ->
  Class['neo4j::config'] ~>
  Class['neo4j::service']
}
