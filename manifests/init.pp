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
# Community: http://download.neo4j.org/artifact?edition=community&version=2.1.2&distribution=tarball
class lw_neo4j (
  $version = '2.1.2',
  $edition = 'community',
  $install_prefix = '/opt/neo4j',

  #server options
  $allow_remote_connections = true, # allows remote connections
  $jvm_init_memory = '512',  # enter size in MBs
  $jvm_max_memory = '512',  # enter size in MBs

  # low-level graph engine options
  $nodestore_memory = undef,
  $relationshipstore_memory = undef,
  $propertystore_memory = undef,
  $propertystore_strings_memory = undef,
  $propertystore_arrays_memory = undef,
)
{
  $package_name = "neo4j-${edition}-${version}"
  $package_tarball = "${package_name}.tgz"

  if($kernel != 'Linux') {
    fail("Only Linux is supported at this time.")
  }


  user { 'neo4j':
    ensure => present,
    gid => 'neo4j',
    shell => '/bin/bash',
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

  # get the tgz file
  exec { "wget ${package_tarball}" :
    command => "wget \"http://download.neo4j.org/artifact?edition=${edition}&version=${version}&distribution=tarball\" -O ${install_prefix}/$package_tarball",
    creates => "${install_prefix}/${package_tarball}",
    notify  => Exec["untar ${package_tarball}"],
    require => File[$install_prefix],
  }

  # untar the tarball at the desired location
  exec { "untar ${package_tarball}":
      command => "tar -xzf ${install_prefix}/${package_tarball} -C ${install_prefix}/; chown neo4j:neo4j -R ${install_prefix}",
      refreshonly => true,
      require => [Exec ["wget ${package_tarball}"], File[$install_prefix]],
  }

  #install the service
  file {'/etc/init.d/neo4j':
    ensure=>link,
    target=>"${install_prefix}/${package_name}/bin/neo4j",
    require => Exec["untar ${package_tarball}"],
  }

  # Track the configuration files
  file { 'neo4j.properties':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j.properties",
    content  => template('lw_neo4j/neo4j.properties.erb'),
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
  file { 'neo4j-server.properties':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j-server.properties",
    content  => template('lw_neo4j/neo4j-server.properties.erb'),
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
  file { 'neo4j-wrapper.conf':
    ensure  => file,
    path    => "${install_prefix}/${package_name}/conf/neo4j-wrapper.conf",
    content  => template('lw_neo4j/neo4j-wrapper.conf.erb'),
    require => Exec["untar ${package_tarball}"],
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  service{'neo4j':
    ensure=>running,
    enable=>true,
    require=>File['/etc/init.d/neo4j'],
  }
}
