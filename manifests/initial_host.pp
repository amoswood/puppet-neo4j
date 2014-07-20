# == Define: user
#
# An initial_host of the Neo4j ha cluster.
#
#  **Note: This is an internal class and should not be called directly.
#
# === Parameters
#
# === Authors
#
# Amos Wood <amosjwood@gmail.com>
#
# === Copyright
#
# Copyright 2014 Amos Wood, unless otherwise noted.
#
define neo4j::initial_host (
  $ip,
  $ha_cluster_name,
  $ha_cluster_port = 5001,
) {
  $fragment_file = $::neo4j::properties_file

  concat::fragment{ "${title} fragment ":
    target  => $fragment_file,
    content => "${ip}:${ha_cluster_port},",
    order   => 10,
  }
}
