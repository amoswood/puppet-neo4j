$users = {
  puppetUser1 => {
    ensure     => absent,
    password   => 'puppet',
    readWrite  => true,
  },
  puppetUser2 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => true,
  },
  puppetUser10 => {
    ensure     => present,
    password   => 'puppet',
    readWrite  => false,
  },
}

class { 'lw_neo4j' :
  version => '2.1.2',
  edition => 'enterprise',
  install_prefix => '/opt/neo4j',
  jvm_init_memory => '1024',
  jvm_max_memory => '1024',
  allow_remote_connections => true,
  use_auth => true,
  admin_user => 'puppetAdmin',
  admin_password => 'puppet',
  users => $users,
}
