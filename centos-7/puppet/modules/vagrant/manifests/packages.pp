# Pre-install packages Vagrant likes
class vagrant::packages {
  package { [
      'nfs-utils',
      'portmap',
    ]:
    ensure => installed,
  }
}