# == Class: neo4j::install
#
# Installs Neo4J (http://www.neo4j.com) on RHEL/Ubuntu/Debian from their
# distribution tarballs downloaded directly from their site.
#
#
# === Authors
#
# Amos Wood <amosjwood@gmail.com>
#
# === Copyright
#
# Copyright 2014 Amos Wood, unless otherwise noted.
#
class neo4j::install ()
{

  file { $neo4j::install_prefix:
    ensure => directory,
  }

  file { "${neo4j::install_prefix}/data":
    ensure => directory,
  }

  if ! defined(Package['wget']) {
    package { 'wget' : }
  }
  if ! defined(Package['tar']) {
    package { 'tar' : }
  }

  # get the tgz file
  exec { "wget ${neo4j::package_tarball}" :
    command => "wget \"http://www.neo4j.com/customer/download/${neo4j::package_name}-unix.tar.gz\" -O ${neo4j::install_prefix}/${neo4j::package_tarball}",
    creates => "${neo4j::install_prefix}/${neo4j::package_tarball}",
    notify  => Exec["untar ${neo4j::package_tarball}"],
    require => [Package['wget'], File[$neo4j::install_prefix]],
  }

  # untar the tarball at the desired location
  exec { "untar ${neo4j::package_tarball}":
      command     => "tar -xzf ${neo4j::install_prefix}/${neo4j::package_tarball} -C ${neo4j::install_prefix}/; chown neo4j:neo4j -R ${neo4j::install_prefix}",
      refreshonly => true,
      require     => [Exec["wget ${neo4j::package_tarball}"], File[$neo4j::install_prefix], Package['tar']],
  }

  #install the service
  file {'/etc/init.d/neo4j':
    ensure  => link,
    target  => "${neo4j::install_prefix}/${neo4j::package_name}/bin/neo4j",
    require => Exec["untar ${neo4j::package_tarball}"],
  }
}
