# == Class: neo4j::config
#
# Config Neo4J (http://www.neo4j.com) on RHEL/Ubuntu/Debian from their
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
class neo4j::config ()
{
  # Track the configuration files
  file { 'neo4j-server.properties':
    ensure  => file,
    path    => "${neo4j::install_prefix}/${neo4j::package_name}/conf/neo4j-server.properties",
    content => template('neo4j/neo4j-server.properties.erb'),
    mode    => '0600',
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }

  $properties_file = "${neo4j::install_prefix}/${neo4j::package_name}/conf/neo4j.properties"

  concat{ $properties_file :
    owner  => 'neo4j',
    group  => 'neo4j',
    mode   => '0644',
    before => Service['neo4j'],
    notify => Service['neo4j'],
  }

  concat::fragment{ 'neo4j properties header':
    target  => $properties_file,
    content => template('neo4j/neo4j.properties.concat.1.erb'),
    order   => 01,
  }

  concat::fragment{ 'neo4j properties ha_initial_hosts':
    target  => $properties_file,
    content => 'ha.initial_hosts=',
    order   => 02,
  }

  concat::fragment{ 'neo4j properties footer':
    target  => $properties_file,
    content => "\n\n#End of file\n",
    order   => 99,
  }

  file { 'neo4j-wrapper.conf':
    ensure  => file,
    path    => "${neo4j::install_prefix}/${neo4j::package_name}/conf/neo4j-wrapper.conf",
    content => template('neo4j/neo4j-wrapper.conf.erb'),
    mode    => '0600',
    before  => Service['neo4j'],
    notify  => Service['neo4j'],
  }
}
