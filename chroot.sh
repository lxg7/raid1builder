#!/bin/bash


grub-install $disk1
grub-install $disk2
update-initramfs -u
sed '8i\GRUB_RECORDFAIL_TIMEOUT=10' /etc/default/grub
sed "s/quiet/quiet bootdegraded/" -i /etc/default/grub
update-grub
dpkg-reconfigure -p critical mdadm