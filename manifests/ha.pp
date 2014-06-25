class lw_neo4j::ha
{
  $ha_server_id = $lw_neo4j::ha_server_id,
  $ha_port = $lw_neo4j::ha_port,
  $ha_initial_hosts = $lw_neo4j::ha_initial_hosts,
  $ha_data_port = '6001',
  $ha_initial_hosts = undef,
  $ha_pull_interval = undef,
  $ha_tx_push_factor = undef,
  $ha_tx_push_strategy = undef,
  $ha_allow_init_cluster = true,
  $ha_slave_only = false,
}
