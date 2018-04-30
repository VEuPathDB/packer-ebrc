# Create vmbuilder account with sudo permission.
class vmbuilder::vmbuilder_user {

  $user = 'vmbuilder'
  $svn_username = lookup('svncredentials_username')
  $svn_password = lookup('svncredentials_password')
  $svn_realmstring = '<https://cbilsvn.pmacs.upenn.edu:443> SVN Repo'

  User[$user] -> Svncredentials[$user]

  Svncredentials { $user:
    home_path       => "/home/${user}",
    owner           => $user,
    svn_realmstring => $svn_realmstring,
    svn_username    => $svn_username,
    svn_password    => $svn_password,
  }

  group { $user:
    ensure => present,
    gid    => '60002',
  }

  group { 'eupa':
    ensure => present,
    gid    => '700',
  }

  user { $user:
    ensure     => present,
    uid        => '60002',
    managehome => true,
    password   => '$1$28j82$O4U8SYWisuYd2lo/G7b031', # vmbuilder
    gid        => $user,
    groups     => [ $user, 'eupa'],
    shell      => '/bin/bash',
    require    => Group[$user],
  }

  file { "/home/${user}/.ssh":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0600',
    require => User[$user],
  }

  ssh_authorized_key { $user:
    ensure => present,
    user   => $user,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
    type   => 'ssh-rsa',
  }

  file { "/etc/sudoers.d/10_${user}":
    source => "puppet:///modules/${user}/10_${user}",
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

  file { "/etc/profile.d/sqlplus.sh":
    source => "puppet:///modules/profiles/profile.d/sqlplus.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

}
