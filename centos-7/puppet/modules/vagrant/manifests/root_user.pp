# Prepare root account for Vagrant
class vagrant::root_user {
  user { 'root':
    managehome => false,
    password   => '$1$wBXGTRZ9$z8esySNE1sjAl9HSLwXMn1', # vagrant
  }
}