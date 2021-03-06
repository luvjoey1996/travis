#version=DEVEL
# Use network installation
url --url="https://mirror.math.princeton.edu/pub/centos-vault/altarch/7.4.1708/os/aarch64/"
repo --name="CentOS" --baseurl=https://mirror.math.princeton.edu/pub/centos-vault/altarch/7.4.1708/os/aarch64/ --cost=100
# Firewall configuration
firewall --disabled
firstboot --disable
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts=''
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=link --activate
network  --hostname=localhost.localdomain
# Shutdown after installation
shutdown
# Root password
rootpw --iscrypted --lock locked
# SELinux configuration
selinux --enforcing
# System services
services --disabled="chronyd"
# Do not configure the X Window System
skipx
# System timezone
timezone UTC --isUtc --nontp
# System bootloader configuration
bootloader --disabled
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="ext4" --size=3000

%post --logfile=/anaconda-post.log
# Post configure tasks for Docker

# remove stuff we don't need that anaconda insists on
# kernel needs to be removed by rpm, because of grubby
rpm -e kernel

yum -y remove bind-libs bind-libs-lite dhclient dhcp-common dhcp-libs \
  dracut-network e2fsprogs e2fsprogs-libs ebtables ethtool file \
  firewalld freetype gettext gettext-libs groff-base grub2 grub2-tools \
  grubby initscripts iproute iptables kexec-tools libcroco libgomp \
  libmnl libnetfilter_conntrack libnfnetlink libselinux-python lzo \
  libunistring os-prober python-decorator python-slip python-slip-dbus \
  snappy sysvinit-tools which linux-firmware GeoIP firewalld-filesystem

yum clean all

#clean up unused directories
rm -rf /boot
rm -rf /etc/firewalld

# Lock roots account, keep roots account password-less.
passwd -l root

#LANG="en_US"
#echo "%_install_lang $LANG" > /etc/rpm/macros.image-language-conf

awk '(NF==0&&!done){print "override_install_langs=en_US.utf8\ntsflags=nodocs";done=1}{print}' \
    < /etc/yum.conf > /etc/yum.conf.new
mv /etc/yum.conf.new /etc/yum.conf
echo 'container' > /etc/yum/vars/infra


##Setup locale properly
# Commenting out, as this seems to no longer be needed
#rm -f /usr/lib/locale/locale-archive
#localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

## Remove some things we don't need
rm -rf /var/cache/yum/x86_64
rm -f /tmp/ks-script*
rm -rf /var/log/anaconda
rm -rf /tmp/ks-script*
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
# do we really need a hardware database in a container?
rm -rf /etc/udev/hwdb.bin
rm -rf /usr/lib/udev/hwdb.d/*

## Systemd fixes
# no machine-id by default.
:> /etc/machine-id
# Fix /run/lock breakage since it's not tmpfs in docker
umount /run
systemd-tmpfiles --create --boot
# Make sure login works
rm /var/run/nologin


#Generate installtime file record
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME


%end

%packages --excludedocs --nocore --instLangs=en
bash
bind-utils
bind-libs
bind-license
bind-libs-lite
dhclient
centos-release
iproute
iputils
kexec-tools
less
passwd
rootfiles
systemd
tar
vim-minimal
yum
yum-plugin-ovl
yum-utils
GeoIP
firewalld-filesystem
-*firmware
-freetype
-gettext*
-kernel*
-libteam
-os-prober
-teamd

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end