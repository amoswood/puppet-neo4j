define lw_neo4j::user(
  $ensure = present,
  $password,
  $readWrite = true,
){
  $user = $title
  $install_prefix = $lw_neo4j::install_prefix
  $package_name = $lw_neo4j::package_name
  $admin_user = $lw_neo4j::admin_user
  $admin_password = $lw_neo4j::admin_password

  $auth_endpoint = "http://${::ipaddress}:7474/auth"

  $user_command = "curl -XGET --silent --user \"${admin_user}:${admin_password}\" ${auth_endpoint}/list | grep -oE \"${user}:[^,}]*\""
  $count_command = "curl -XGET --silent --user \"${admin_user}:${admin_password}\" ${auth_endpoint}/list | grep -oE ${user}: | wc -l"

  if($readWrite) {
    $readWriteValue = 1
    $readWriteString = 'RW'
  }
  else {
    $readWriteValue = 0
    $readWriteString = 'RO'
  }

  Exec {
    path => ["${install_prefix}/${package_name}/bin", '/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }

  if($ensure != absent and $ensure != purged) {
    #Create the users if they don't exist
    exec { "Create Neo4j User ${user}" :
      command => "createNeo4jUser ${auth_endpoint} \"${admin_user}:${admin_password}\" ${user} \"${password}\" ${readWriteValue}",
      onlyif => "test `${count_command}` -eq 0",
      require => File['createNeo4jUser.sh', 'authentication-extension'],
    }
    exec { "Update Neo4j User ${user}" :
      command => "updateNeo4jUser ${auth_endpoint} \"${admin_user}:${admin_password}\" ${user} \"${password}\" ${readWriteValue}",
      onlyif => "test \"`${user_command}`\" != \"${user}:${password}\\\":\\\"${readWriteString}\\\"\"",
      require => [Exec["Create Neo4j User ${user}"], File['updateNeo4jUser.sh', 'authentication-extension']],
    }
  }
  # remove the user
  else {
    exec { "Remove Neo4j User ${user}" :
      command => "removeNeo4jUser ${auth_endpoint} \"${admin_user}:${admin_password}\" ${user}",
      onlyif => "test `${count_command}` -gt 0",
      require => File['removeNeo4jUser.sh', 'authentication-extension'],
    }
  }
}
