# prepare a VM for use with Vagrant
class vagrant {
  contain vagrant::vagrant_user
  contain vagrant::root_user
}