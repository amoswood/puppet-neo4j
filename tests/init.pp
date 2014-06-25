$users = {
  user1 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => true,
  },
  user2 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => true,
  },
  user10 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => false,
  },
}

class { 'neo4j' :
  version => '2.1.2',
  edition => 'enterprise',
  install_prefix => '/opt/neo4j',
  jvm_init_memory => '1024',
  jvm_max_memory => '1024',
  allow_remote_connections => true,
  use_auth => true,
  admin_user => 'admin',
  admin_password => 'password',
  users => $users,
  newrelic_ensure => absent,
}
