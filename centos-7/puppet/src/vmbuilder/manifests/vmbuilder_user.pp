# Create vmbuilder account with sudo permission.
class vmbuilder::vmbuilder_user {

  include ::profiles::vmbuilder_cbil_svn_auth
  User['vmbuilder'] -> Class['::profiles::vmbuilder_cbil_svn_auth']

  group { 'vmbuilder':
    ensure => present,
    gid    => '60001',
  }

  group { 'eupa':
    ensure => present,
    gid    => '700',
  }

  user { 'vmbuilder':
    ensure     => present,
    uid        => '60001',
    managehome => true,
    password   => '$1$28j82$O4U8SYWisuYd2lo/G7b031', # vmbuilder
    gid        => 'vmbuilder',
    groups     => [ 'vmbuilder', 'eupa'],
    shell      => '/bin/bash',
    require    => Group[ 'vmbuilder' ],
  }

  file { '/home/vmbuilder/.ssh':
    ensure  => directory,
    owner   => 'vmbuilder',
    group   => 'vmbuilder',
    mode    => '0600',
    require => User[ 'vmbuilder' ],
  }

  ssh_authorized_key { 'vmbuilder':
    ensure => present,
    user   => 'vmbuilder',
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
    type   => 'ssh-rsa',
  }

  file { '/etc/sudoers.d/10_vmbuilder':
    source => 'puppet:///modules/vmbuilder/10_vmbuilder',
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
  }

}
