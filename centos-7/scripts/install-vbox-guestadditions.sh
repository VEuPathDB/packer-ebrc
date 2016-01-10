yum install -y bzip2
yum install -y kernel-devel
yum install -y gcc

# Fix for OpenGL?
## Seems not. Apparently 5.0.10 is broken for EL 7.2 (https://www.virtualbox.org/ticket/14866)
# cd /usr/src/kernels/$(uname -r)/include/drm 
# ln -s /usr/include/drm/drm.h drm.h  
# ln -s /usr/include/drm/drm_sarea.h drm_sarea.h  
# ln -s /usr/include/drm/drm_mode.h drm_mode.h  
# ln -s /usr/include/drm/drm_fourcc.h drm_fourcc.h
# cd /usr/src/kernels/$(uname -r)/include/linux
# ln -s ../generated/autoconf.h 

mkdir /tmp/isomount
mount -t iso9660 -o loop /root/VBoxGuestAdditions.iso /tmp/isomount
/tmp/isomount/VBoxLinuxAdditions.run
umount /tmp/isomount
rm -rf /tmp/isomount
rm -f /root/VBoxGuestAdditions.iso