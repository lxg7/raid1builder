#!/bin/bash

ROOT_UID=0 # Только пользователь с $UID 0 имеет привилегии root.
E_NOTROOT=67 # Признак отсутствия root-привилегий.
E_FILE_NOT_EXIST=71
E_NOFILE=66


function choosedisk1 {
  echo  -n "Будет ли текущий диск частью будущего массива?(y/n) "
  read def_disk_in_root
    
  case $def_disk_in_root in
  "y" | "Y" | "YES" | "yes" | "Yes" )
    echo "Текущий диск будет вхоить в систему..."
    disk1=`df | grep "/$" | awk '{print $1}'`
    echo "Текущий диск $disk1 выбран как первый в массиве"
    echo "Текущие параметры еще не поддерживаются..."
    exit 1 
  ;;
  
  "n" | "N" | "no" | "NO" | "No" )
    echo "Текущий диск не будет вхоить в систему..."
    echo "Введите название нового диска_1 дл массива(/dev/sdX)): "
    read disk1
    disk1_check=`echo $disk1 | tail -c 4`
    if [ $disk1_check == `lsblk | grep $disk1_check | awk '{print $1}'` ]
    then
      echo "Диск определен: $disk1"
    else
      echo "Ошибка! Нет такого диска..."
      exit 1
    fi
  ;;

  * )
    echo -n "unknown" ;;
  esac
}

function choosedisk2 {
  echo "Введите название нового диска_2 дл массива(/dev/sdX)): "
  read disk2
  disk2_check=`echo $disk2 | tail -c 4`
  if [ $disk2_check == `lsblk | grep $disk2_check | awk '{print $1}'` ]
  then
    echo "Диск определен: $disk2"
  else
    echo "Ошибка! Нет такого диска..."
    exit 1
  fi
  
}

function makeraid0 {
    echo "Выбран RAID-0."
    echo "В разработке..."
    exit 1
    #=====================
}

function makeraid1 {
  echo  "Выбран RAID-1."
  choosedisk1
  choosedisk2
echo;echo;echo;echo;echo
echo "====Форматирование дисков===="
echo "Форматирование диска $disk1"

parted -s $disk1 mklabel msdos
parted -s $disk1 mkpart primary 1MiB 100%
parted -s $disk1 set 1 raid on
disk11=`echo "$disk1"1`
read check 

echo "Форматирование диска $disk2"

parted -s $disk2 mklabel msdos
parted -s $disk2 mkpart primary 1MiB 100%
parted -s $disk2 set 1 raid on
disk21=`echo "$disk2"1`
read check

echo;echo;echo;echo;echo
echo "====Создание диска md0 - RAID-1 ===="
mdadm --verbose --create /dev/md0 --level=1 --raid-devices=2 $disk11 $disk21
mdadm -D /dev/md0
mdadm --examine --scan > /etc/mdadm/mdadm.conf
read check

echo;echo;echo;echo;echo
echo "====Разметка md0 + форматирование ===="
sfdisk -d /dev/sda | sfdisk -f /dev/md0
mkfs.ext4 /dev/md0p1
mkswap /dev/md0p5
read check

echo;echo;echo;echo;echo
echo "====Перенос данных со старой системы===="
mount /dev/md0p1 /mnt
rsync -axuP / /mnt/
read check

echo;echo;echo;echo;echo
echo "====Меняем fstab на raid-системе===="
uuidsda1=`ls -l /dev/disk/by-uuid/ | grep sda1 | awk '{print $9}'`
uuidmd0p1=`ls -l /dev/disk/by-uuid/ | grep md0p1 | awk '{print $9}'`
sed "s/$uuidsda1/$uuidmd0p1/" -i /etc/fstab

uuidsda5=`ls -l /dev/disk/by-uuid/ | grep sda5 | awk '{print $9}'`
uuidmd0p5=`ls -l /dev/disk/by-uuid/ | grep md0p5 | awk '{print $9}'`
sed "s/$uuidsda5/$uuidmd0p5/" -i /etc/fstab
read check

echo;echo;echo;echo;echo
echo "====chroot===="
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
read check

echo;echo;echo;echo;echo
echo "====Обновление конфигов grub и установка на новые диски===="
# cat /boot/grub/grub.cfg | grep UUID_нового_системного_раздела
grub-install $disk1
grub-install $disk2
echo '====Переходим в новое окружение'
cp chroot.sh /mnt/chroot.sh
chroot /mnt/ /chroot.sh
echo "chroot ok"
echo
echo "!!!RAID готов!!!
echo
read check
reboot

}

function inst_req {
  # Проверка наличия необходимых программ
  command -v mdadm >/dev/null 2>&1 || { echo >&2 "I require mdadm but it's not installed.  Aborting."; exit 1; }
  command -v parted >/dev/null 2>&1 || { echo >&2 "I require parted but it's not installed.  Aborting."; exit 1; }
  command -v rsync >/dev/null 2>&1 || { echo >&2 "I require rsync but it's not installed.  Aborting."; exit 1; }
  # command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
  echo "Все программы установлены (mdadm, parted, rsync)"

}

function root_check {
  if [ "$UID" -ne "$ROOT_UID" ]
  then
    echo "Для работы сценария требуются права root."
    exit $E_NOTROOT
  fi
  echo "Root - права получены"
}


function requirements {
  echo "  _____            _____ _____   ____        _ _     _           "; sleep .1
  echo " |  __ \     /\   |_   _|  __ \ |  _ \      (_) |   | |          "; sleep .1
  echo " | |__) |   /  \    | | | |  | || |_) |_   _ _| | __| | ___ _ __ "; sleep .1
  echo " |  _  /   / /\ \   | | | |  | ||  _ <| | | | | |/ _\` |/ _ \ '__|";sleep .1
  echo " | | \ \  / ____ \ _| |_| |__| || |_) | |_| | | | (_| |  __/ |   "; sleep .1
  echo " |_|  \_\/_/    \_\_____|_____/ |____/ \__,_|_|_|\__,_|\___|_|   "; sleep .1
  echo "                            ______                               "; sleep .1
  echo "  _             _          |______|                              "; sleep .1
  echo " | |           | |        |____  |                               "; sleep .1
  echo " | |__  _   _  | |_  ____ _   / /                                "; sleep .1
  echo " | '_ \| | | | | \ \/ / _\` | / /                                 ";sleep .1
  echo " | |_) | |_| | | |>  < (_| |/ /                                  "; sleep .1
  echo " |_.__/ \__, | |_/_/\_\__, /_/                                   "; sleep .1
  echo "         __/ |         __/ |                                     "; sleep .1
  echo "        |___/         |___/                                      "; sleep .1
  echo
  echo "--- Для работы необохдимо:"
  echo "---   1. Диск с MBR разметкой (разделы Авто - /home и swap)"
  echo "---   2. Пакеты mdadm, parted, rsync"
  echo "--- Пока работает только вариант с RAID-1 для двух новых дисков(без текущего)."
  echo
}



requirements
root_check
inst_req

echo -n "Enter RAID level(0,1): "
read rraidlevel

#echo -n "Выбран $raidlevel : "

case $rraidlevel in

  RAID0 | raid0 | 0)
    #makeraid0
    echo "В разработке..."
	exit 1
	;;

  RAID1 | raid1 | 1)
    makeraid1
	exit 0
    ;;
	
  *)
    echo "Ошибка. Тип массива не распознан."
    ;;
esac


