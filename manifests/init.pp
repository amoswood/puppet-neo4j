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
  $ha_initial_hosts = undef,

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
    if($ha_initial_hosts == false) {
      fail('When running as HA you need to declare your seed hosts using ha_initial_hosts.')
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

  file { $install_prefix:
    ensure => directory,
  }

  file { "${install_prefix}/data":
    ensure => directory,
  }

  if ! defined(Package['wget']) {
    package { 'wget' : }
  }
  if ! defined(Package['tar']) {
    package { 'tar' : }
  }

  # get the tgz file
  exec { "wget ${package_tarball}" :
    command => "wget \"http://www.neo4j.com/customer/download/${package_name}-unix.tar.gz\" -O ${install_prefix}/${package_tarball}",
    creates => "${install_prefix}/${package_tarball}",
    notify  => Exec["untar ${package_tarball}"],
    require => [Package['wget'], File[$install_prefix]],
  }

  # untar the tarball at the desired location
  exec { "untar ${package_tarball}":
      command     => "tar -xzf ${install_prefix}/${package_tarball} -C ${install_prefix}/; chown neo4j:neo4j -R ${install_prefix}",
      refreshonly => true,
      require     => [Exec["wget ${package_tarball}"], File[$install_prefix], Package['tar']],
  }

  #install the service
  file {'/etc/init.d/neo4j':
    ensure  => link,
    target  => "${install_prefix}/${package_name}/bin/neo4j",
    require => Exec["untar ${package_tarball}"],
  }

  # Track the configuration files
  file { 'neo4j-server.properties':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j-server.properties",
    content => template('neo4j/neo4j-server.properties.erb'),
    mode    => '0600',
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  $properties_file = "${install_prefix}/${package_name}/conf/neo4j.properties"

  concat{ $properties_file :
    owner   => 'neo4j',
    group   => 'neo4j',
    mode    => '0644',
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  concat::fragment{ 'neo4j properties header':
    target  => $properties_file,
    content => template('neo4j/neo4j.properties.concat.1.erb'),
    order   => 01,
  }

  if ($ha_ensure != absent) {
    concat::fragment{ 'neo4j properties ha_initial_hosts':
      target  => $properties_file,
      content => "ha.initial_hosts=${ha_initial_hosts}",
      order   => 02,
    }
  }

  concat::fragment{ 'neo4j properties footer':
    target  => $properties_file,
    content => "\n\n#End of file\n",
    order   => 99,
  }

  file { 'neo4j-wrapper.conf':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j-wrapper.conf",
    content => template('neo4j/neo4j-wrapper.conf.erb'),
    mode    => '0600',
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  service{'neo4j':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File['/etc/init.d/neo4j'],
  }

  if($auth_ensure != absent) {
    #determine the plugin version
    if(versioncmp($version, '2.1.0') >= 0) {
      $authentication_plugin_name = 'authentication-extension-2.1.2-1.0-SNAPSHOT.jar'
    } elsif(versioncmp($version, '2.0.0') >= 0) {
      $authentication_plugin_name = 'authentication-extension-2.0.3-1.0-SNAPSHOT.jar'
    } else {
      fail("Authenitcation in version ${version} is not supported. It is only available in version >= 2.0.0.")
    }

    if( ! $auth_admin_user or ! $auth_admin_password) {
      fail('An admin user (auth_admin_user) and password (auth_admin_password) must be set when auth_ensure is true.')
    }

    file { 'authentication-extension' :
      ensure  => file,
      path    => "${install_prefix}/${package_name}/plugins/${authentication_plugin_name}",
      source  => "puppet:///modules/neo4j/${authentication_plugin_name}",
      notify  => Service['neo4j'],
      require => Exec["untar ${package_tarball}"],
    }

    # Track the user management files
    file { 'createNeo4jUser.sh':
      ensure  => file,
      path    => "${install_prefix}/${package_name}/bin/createNeo4jUser",
      source  => 'puppet:///modules/neo4j/createNeo4jUser.sh',
      mode    => '0755',
      require => Exec["untar ${package_tarball}"],
    }
    file { 'updateNeo4jUser.sh':
      ensure  => file,
      path    => "${install_prefix}/${package_name}/bin/updateNeo4jUser",
      source  => 'puppet:///modules/neo4j/updateNeo4jUser.sh',
      mode    => '0755',
      require => Exec["untar ${package_tarball}"],
    }
    file { 'removeNeo4jUser.sh':
      ensure  => file,
      path    => "${install_prefix}/${package_name}/bin/removeNeo4jUser",
      source  => 'puppet:///modules/neo4j/removeNeo4jUser.sh',
      mode    => '0755',
      require => Exec["untar ${package_tarball}"],
    }

    if(is_hash($auth_users)) {
      create_resources(neo4j::user, $auth_users)
    }
  }
}
