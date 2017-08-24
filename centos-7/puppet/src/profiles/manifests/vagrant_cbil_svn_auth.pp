# Create, install an svn auth credentials file.
# This is so automated process have pre-configured credentials
# for svn checkout.
class profiles::vagrant_cbil_svn_auth (
  String $svn_username    = undef,
  String $svn_password    = undef,
) {

  $owner           = 'vagrant'
  $home            = '/home/vagrant'
  $svn_realmstring = '<https://cbilsvn.pmacs.upenn.edu:443> SVN Repo'

  Svncredentials { 'vagrant':
    home_path       => $home,
    owner           => $owner,
    svn_realmstring => $svn_realmstring,
    svn_username    => $svn_username,
    svn_password    => $svn_password,
  }

}