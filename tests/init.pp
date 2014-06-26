$auth_users = {
  user1 => {
    ensure     => present,
    password   => 'puppet',
  },
  user2 => {
    password   => 'puppet',
    readWrite  => false,
  },
  user3 => {
    ensure     => absent,
    password   => '',
  },
}

class { 'neo4j' :
  version                  => '2.1.2',
  edition                  => 'enterprise',
  install_prefix           => '/opt/neo4j',
  jvm_init_memory          => '1024',
  jvm_max_memory           => '1024',
  allow_remote_connections => true,
  auth_ensure              => present,
  auth_admin_user          => 'admin',
  auth_admin_password      => 'password',
  auth_users               => $auth_users,
  newrelic_ensure          => absent,
}
