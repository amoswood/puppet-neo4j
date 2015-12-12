# == Class: neo4j
#
# Installs Neo4J (http://www.neo4j.com) on RHEL/Ubuntu/Debian from their
# distribution tarballs downloaded directly from their site.
#
# === Authors
#
# Amos Wood <amosjwood@gmail.com>
#
# === Copyright
#
# Copyright 2014 Amos Wood, unless otherwise noted.
#
class neo4j::authentication ()
{

  #determine the plugin version
  if(versioncmp($neo4j::version, '2.1.0') >= 0) {
    $authentication_plugin_name = 'authentication-extension-2.1.2-1.0-SNAPSHOT.jar'
  } elsif(versioncmp($neo4j::version, '2.0.0') >= 0) {
    $authentication_plugin_name = 'authentication-extension-2.0.3-1.0-SNAPSHOT.jar'
  } else {
    fail("Authenitcation in version ${neo4j::version} is not supported. It is only available in version >= 2.0.0.")
  }

  if( ! $neo4j::auth_admin_user or ! $neo4j::auth_admin_password) {
    fail('An admin user (auth_admin_user) and password (auth_admin_password) must be set when auth_ensure is true.')
  }

  file { 'authentication-extension' :
    ensure => file,
    path   => "${neo4j::install_prefix}/${neo4j::package_name}/plugins/${authentication_plugin_name}",
    source => "puppet:///modules/neo4j/${authentication_plugin_name}",
    require => Class['neo4j::install'],
    notify => Service['neo4j'],
  }

  # Track the user management files
  file { 'createNeo4jUser.sh':
    ensure => file,
    path   => "${neo4j::install_prefix}/${neo4j::package_name}/bin/createNeo4jUser",
    source => 'puppet:///modules/neo4j/createNeo4jUser.sh',
    require => Class['neo4j::install'],
    mode   => '0755',
  }
  file { 'updateNeo4jUser.sh':
    ensure => file,
    path   => "${neo4j::install_prefix}/${neo4j::package_name}/bin/updateNeo4jUser",
    source => 'puppet:///modules/neo4j/updateNeo4jUser.sh',
    require => Class['neo4j::install'],
    mode   => '0755',
  }
  file { 'removeNeo4jUser.sh':
    ensure => file,
    path   => "${neo4j::install_prefix}/${neo4j::package_name}/bin/removeNeo4jUser",
    source => 'puppet:///modules/neo4j/removeNeo4jUser.sh',
    require => Class['neo4j::install'],
    mode   => '0755',
  }

  if(is_hash($neo4j::auth_users)) {
    create_resources(neo4j::user, $neo4j::auth_users)
  }
}
