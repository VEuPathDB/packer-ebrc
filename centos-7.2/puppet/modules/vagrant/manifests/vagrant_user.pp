# Create vagrant account with sudo permission.
class vagrant::vagrant_user {

  group { 'vagrant':
    ensure => present,
  }

  user { 'vagrant':
    ensure     => present,
    managehome => true,
    password   => '$1$wBXGTRZ9$z8esySNE1sjAl9HSLwXMn1', # vagrant
    gid        => 'vagrant',
    groups     => [ 'vagrant', ],
    shell      => '/bin/bash',
    require    => Group[ 'vagrant' ],
  }

  file { "/home/vagrant/.ssh":
    ensure  => directory,
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0600',
    require => User[ 'vagrant' ],
  }

  ssh_authorized_key { 'vagrant':
    ensure  => present,
    user    => 'vagrant',
    key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
    type    => 'ssh-rsa',
  }

  $sudoer = @(EOF)
    Defaults:vagrant  !requiretty
    %vagrant ALL=(ALL) NOPASSWD: ALL
    | EOF

  file { '/etc/sudoers.d/10_vagrant':
    content => $sudoer,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
  }

}