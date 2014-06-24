class { 'lw_neo4j' :
  version => '2.1.2',
  edition => 'enterprise',
  install_prefix => '/opt/neo4j',
  jvm_init_memory => '1024',
  jvm_max_memory => '1024',
  allow_remote_connections => true,
}
