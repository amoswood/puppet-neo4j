define lw_neo4j::tarball(
  $pkg_tgz,
  $download_path,
  $install_dir)
{
    Exec {
      path => ['/usr/bin', '/usr/local/bin', '/bin', '/sbin'],
    }

    # get the tgz file
    exec { "wget ${pkg_tgz}" :
      command => "wget \"${download_path}\" -O ${install_dir}/${pkg_tgz}",
      creates => "${install_dir}/${pkg_tgz}",
      notify  => Exec["untar $pkg_tgz"],
      require => File[$install_dir],
    }

    # untar the tarball at the desired location
    exec { "untar $pkg_tgz":
        command => "tar -xzf ${install_dir}/$pkg_tgz -C $install_dir/; chown neo4j:neo4j -R $install_dir",
        refreshonly => true,
        require => [Exec ["wget ${pkg_tgz}"], File[$install_dir]],
    }
}
