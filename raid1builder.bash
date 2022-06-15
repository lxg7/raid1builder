#!/bin/bash

ROOT_UID=0 # Только пользователь с $UID 0 имеет привилегии root.
E_NOTROOT=67 # Признак отсутствия root-привилегий.
E_FILE_NOT_EXIST=71
E_NOFILE=66


function choosedisk1 {
  echo  -n "Будет ли текущий диск частью будущего массива?(y/n) "
  read def_disk_in_root
    
  case "$def_disk_in_root" in
  
  y | Y | YES | yes | Yes)
    echo -n "Текущий диск будет вхоить в систему..."
    disk1 = `df | grep "/$" | awk '{print $1}'`
    echo "Текущий диск $disk1 выбран как первый в массиве"
    echo "Текущие параметры еще не поддерживаются..."
    exit 1
  ;;
  
  n | N | no | NO | No)
    echo -n "Текущий диск не будет вхоить в систему..."
    echo "Введите название нового диска1 дл массива(/dev/sdX)): "
    read disk1
    disk1_check = `disk1 | tail -c 3
    echo disk1_check
    if ["$disk1_check" == `lsblk | grep disk1_check` ]
    echo "Диск определен: $disk1"
  ;;

  *)
  echo -n "unknown"
  ;;
  esac

}

function makeraid0 {
    echo  "Выбран RAID-0."
    echo  "В данный момент не поддерживается..."
    exit 1
echo

    if def_disk_in_root == 'y'
    then
      
    else
      echo -n "Текущий диск не будет вхоить в систему..."
    fi
    #=====================
}

function makeraid1 {
    echo  "Выбран RAID-1."
    #echo  "В данный момент не поддерживается..."
    


}



if [ "$UID" -ne "$ROOT_UID" ]
then
	echo "Для работы сценария требуются права root."
	exit $E_NOTROOT
fi

echo "Root - права получены"


 # Проверка наличия необходимых программ
command -v mdadm >/dev/null 2>&1 || { echo >&2 "I require mdadm but it's not installed.  Aborting."; exit 1; }
command -v parted >/dev/null 2>&1 || { echo >&2 "I require parted but it's not installed.  Aborting."; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo >&2 "I require rsync but it's not installed.  Aborting."; exit 1; }
# command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }

echo "Все программы установлены (mdadm, parted, rsync)"

echo -n "Enter RAID level(0,1): "
read rraidlevel

echo -n "Выбран $raidlevel : "

case $rraidlevel in

  RAID0 | raid0 | 0)
    makeraid0
	exit 1
	;;

  RAID1 | raid1 | 1)
    makeraid1
	exit 1
    ;;
	
  *)
    echo -n "unknown"
    ;;
esac



#echo "Введите диск, на котором стоит система"
#read default_disk

#if [ ! -f "$default_disk" ] # Проверка существования файла.
#then
# echo "Файл \"$default_disk\" не найден."
# exit $E_NOFILE
#fi
#echo "Домашний диск определен - \"$default_disk\""

#def_disk = $1
#disk1 = $2
#disk2 = $3
