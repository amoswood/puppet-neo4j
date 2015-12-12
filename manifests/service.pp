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
class neo4j::service ()
{
  service{'neo4j':
    ensure => $neo4j::service_ensure,
    enable => $neo4j::service_enable
  }
}
