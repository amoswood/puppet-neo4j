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

  #server options
  $allow_remote_connections = true,
  $jvm_init_memory = '1024',
  $jvm_max_memory = '1024',

  # low-level graph engine options
  $nodestore_memory = undef,
  $relationshipstore_memory = undef,
  $propertystore_memory = undef,
  $propertystore_strings_memory = undef,
  $propertystore_arrays_memory = undef,

  #security
  $auth_ensure = absent,
  $auth_admin_user = undef,
  $auth_admin_password = undef,
  $auth_users = undef,

  #newrelic
  $newrelic_ensure = absent,
  $newrelic_license_key = undef,
  $newrelic_agent_version = '3.7.2',
  $newrelic_app_name = $::hostname,
  $newrelic_yml_contents = undef,

  #high availability settings
  $ha_ensure = absent,
  $ha_server_id = undef,
  $ha_cluster_port = '5001',
  $ha_data_port = '6001',
  $ha_initial_hosts = undef,
  $ha_pull_interval = undef,
  $ha_tx_push_factor = undef,
  $ha_tx_push_strategy = undef,
  $ha_allow_init_cluster = true,
  $ha_slave_only = false,
)
{
  $package_name = "neo4j-${edition}-${version}"
  $package_tarball = "${package_name}.tgz"

  if($::kernel != 'Linux') {
    fail('Only Linux is supported at this time.')
  }
  if($version < '2.0.0') {
    fail('Only versions >= 2.0.0 are supported at this time.')
  }
  if($ha_ensure and $ha_ensure == present) {
    validate_re($ha_server_id, '[0-9]+', 'The Server Id value must be specified and must numeric.')

    if(! $ha_initial_hosts) {
      fail('You must specify the initial hosts to connect to for HA.')
    }
  }

  user { 'neo4j':
    ensure => present,
    gid    => 'neo4j',
    shell  => '/bin/bash',
  }
  group { 'neo4j':
    ensure=>present,
  }

  File {
    owner=>'neo4j',
    group=>'neo4j',
    mode=>'0644'
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
    command => "wget \"http://download.neo4j.org/artifact?edition=${edition}&version=${version}&distribution=tarball\" -O ${install_prefix}/${package_tarball}",
    creates => "${install_prefix}/${package_tarball}",
    notify  => Exec["untar ${package_tarball}"],
    require => [Package['wget'], File[$install_prefix]],
  }

  # untar the tarball at the desired location
  exec { "untar ${package_tarball}":
      command     => "tar -xzf ${install_prefix}/${package_tarball} -C ${install_prefix}/; chown neo4j:neo4j -R ${install_prefix}",
      refreshonly => true,
      require     => [Exec ["wget ${package_tarball}"], File[$install_prefix], Package['tar']],
  }

  #install the service
  file {'/etc/init.d/neo4j':
    ensure  => link,
    target  => "${install_prefix}/${package_name}/bin/neo4j",
    require => Exec["untar ${package_tarball}"],
  }

  # Track the configuration files
  file { 'neo4j.properties':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j.properties",
    content => template('neo4j/neo4j.properties.erb'),
    mode    => '0600',
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
  file { 'neo4j-server.properties':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j-server.properties",
    content => template('neo4j/neo4j-server.properties.erb'),
    mode    => '0600',
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
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
    ensure  => running,
    enable  => true,
    require => File['/etc/init.d/neo4j'],
  }

  if($auth_ensure) {
    #determine the plugin version
    if($version >= '2.1.0') {
      $authentication_plugin_name = 'authentication-extension-2.1.2-1.0-SNAPSHOT.jar'
    } elsif($version >= '2.0.0') {
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

  $newrelic_dir_ensure = $newrelic_ensure ? {
    present => directory,
    default => absent,
  }

  file { "${install_prefix}/newrelic" :
    ensure => $newrelic_dir_ensure,
    force  => true,
    notify => Service['neo4j'],
  }

  if($newrelic_ensure and $newrelic_ensure != absent and $newrelic_ensure != purged) {

    validate_re($newrelic_license_key, '[0-9a-fA-F]{40}', 'New Relic license key is not a 40 character hexadecimal string')

    $url = "http://download.newrelic.com/newrelic/java-agent/newrelic-agent/${newrelic_agent_version}/newrelic-agent-${newrelic_agent_version}.jar"
    $newrelic_jar = "${install_prefix}/newrelic/newrelic-agent-${newrelic_agent_version}.jar"

    # get the newrelic agent file
    #http://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.7.2/
    exec { 'wget newrelic-agent.jar' :
      path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      command => "wget \"${url}\" -O ${newrelic_jar}",
      creates => $newrelic_jar,
      notify  => Service['neo4j'],
      require => [File["${install_prefix}/newrelic"], Package['wget']],
    }

    if($::neo4j::newrelic_yml_content) {
      file { 'newrelic.yml' :
        ensure  => file,
        path    => "${install_prefix}/newrelic/newrelic.yml",
        content => $::neo4j::newrelic_yml_content,
        notify  => Service['neo4j'],
      }
    } else {
      file { 'newrelic.yml' :
        ensure  => file,
        path    => "${install_prefix}/newrelic/newrelic.yml",
        content => template('neo4j/newrelic-neo4j.yml.erb'),
        notify  => Service['neo4j'],
      }
    }
  }
}
