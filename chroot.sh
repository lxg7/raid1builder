#!/bin/bash


update-initramfs -u
sed '8i\GRUB_RECORDFAIL_TIMEOUT=10' -i /etc/default/grub
sed "s/quiet/quiet bootdegraded/" -i /etc/default/grub
update-grub
dpkg-reconfigure -p critical mdadm
