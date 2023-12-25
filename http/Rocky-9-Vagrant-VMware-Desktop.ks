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
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers 

dnf update -y

%end
