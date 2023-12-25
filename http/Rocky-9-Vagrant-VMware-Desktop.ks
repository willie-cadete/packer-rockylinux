#version=DEVEL

# Use text install
text

# License agreement
eula --agreed
reboot

# Use CDROM installation media
cdrom
repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

# Keyboard layouts
keyboard --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=link --activate --onboot=on

# System timezone
timezone --utc UTC

# Root password
rootpw --iscrypted $6$acgT4wa061uNIx6x$peJcUT.5FQqKTDxTC/3BL8qBgj2.CzsA3VHM68DdC9X.K7/rfE0gJhJ80BYJnszmaPYyTlp7K4uFH7A3Z7dyb1
user --groups=wheel --name=vagrant --password=$6$yQmzuXUFsguK3f/p$rj/A9YU5BuWLDc6jcLvSoLujwaFy4XW8enKNEjI.CRkuoB6wMBEB0S.xuxKQfqNRi7vwLiz6UBAXI7uvj1iLF. --iscrypted

# Disk Preparation
ignoredisk --only-use=nvme0n1

# Partition clearing information
clearpart --none --initlabel --disklabel=gpt

# Disk partitioning information
part biosboot  --size=1    --fstype=biosboot --asprimary
part /boot/efi --size=100  --fstype=efi      --asprimary
part /boot     --size=1000 --fstype=xfs      --label=boot
part pv.01 --fstype="lvmpv" --grow
volgroup os pv.01
logvol /home --vgname=os --size=20000 --name=home --fstype=xfs
logvol / --vgname=os --size=50000 --name=root --fstype=xfs
logvol swap --vgname=os --size=2000 --name=swap --fstype=swap

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%packages
@^workstation-product-environment
@container-management
git
# Microcode updates cannot work in a VM
-microcode_ctl
# Firmware packages are not needed in a VM
-iwl*-firmware

%end

services --enabled=vmtoolsd

# X Window System configuration information
xconfig  --startxonboot

%post --log=/root/ks-post.log

#Vagrant sudo configuration
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

#Default insecure vagrant key
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Blacklist the floppy module to avoid probing timeouts
echo blacklist floppy > /etc/modprobe.d/nofloppy.conf
chcon -u system_u -r object_r -t modules_conf_t /etc/modprobe.d/nofloppy.conf

# Decrease connection time by preventing reverse DNS lookups
# (see https://lists.centos.org/pipermail/centos-devel/2016-July/014981.html
#  and man sshd for more information)
OPTIONS="-u0"
EOF

# systemd should generate a new machine id during the first boot, to
# avoid having multiple Vagrant instances with the same id in the local
# network. /etc/machine-id should be empty, but it must exist to prevent
# boot errors (e.g.  systemd-journald failing to start).
:>/etc/machine-id

# Customize the initramfs
pushd /etc/dracut.conf.d
# Enable VMware PVSCSI support for VMware Fusion guests.
echo 'add_drivers+=" vmw_pvscsi "' > vmware-fusion-drivers.conf
echo 'add_drivers+=" hv_netvsc hv_storvsc hv_utils hv_vmbus hid-hyperv "' > hyperv-drivers.conf
# There's no floppy controller, but probing for it generates timeouts
echo 'omit_drivers+=" floppy "' > nofloppy.conf
popd
# Fix the SELinux context of the new files
restorecon -f - <<EOF
/etc/sudoers.d/vagrant
/etc/dracut.conf.d/vmware-fusion-drivers.conf
/etc/dracut.conf.d/nofloppy.conf
EOF

# Rerun dracut for the installed kernel (not the running kernel):
KERNEL_VERSION=$(rpm -q kernel --qf '%{version}-%{release}.%{arch}\n')
dracut -f /boot/initramfs-${KERNEL_VERSION}.img ${KERNEL_VERSION}

#Upgrade the whole system
dnf upgrade -y
dnf clean all

# Seal for deployment
rm -rf /etc/ssh/ssh_host_*
hostnamectl set-hostname localhost.localdomain
rm -rf /etc/udev/rules.d/70-*

%end
