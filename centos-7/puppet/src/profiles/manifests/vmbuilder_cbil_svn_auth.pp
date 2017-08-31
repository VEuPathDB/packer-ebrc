# Create, install an svn auth credentials file.
# This is so automated process have pre-configured credentials
# for svn checkout.
class profiles::vmbuilder_cbil_svn_auth (
  String $svn_username    = undef,
  String $svn_password    = undef,
) {

  $owner           = 'vmbuilder'
  $home            = '/home/vmbuilder'
  $svn_realmstring = '<https://cbilsvn.pmacs.upenn.edu:443> SVN Repo'

  Svncredentials { 'vmbuilder':
    home_path       => $home,
    owner           => $owner,
    svn_realmstring => $svn_realmstring,
    svn_username    => $svn_username,
    svn_password    => $svn_password,
  }

}