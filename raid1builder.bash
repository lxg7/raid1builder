#!/bin/bash

ROOT_UID=0 # Только пользователь с $UID 0 имеет привилегии root.
E_NOTROOT=67 # Признак отсутствия root-привилегий.
E_FILE_NOT_EXIST=71
E_NOFILE=66

function makeraid0 {
    echo  "Выбран RAID-0."
    echo  "В данный момент не поддерживается..."
    echo  -n "Будет ли текущий диск частью будущего массива?(y/n) "
    read def_disk_in_root
    if def_disk_in_root == 'y'
    then
      echo -n "Текущий диск будет вхоить в систему..."
    else
      echo -n "Текущий диск не будет вхоить в систему..."
    fi

}

function makeraid1 {
    echo  "Выбран RAID-1."
    echo  "В данный момент не поддерживается..."
    echo  -n "Будет ли текущий диск частью будущего массива?(y/n) "
    read def_disk_in_root
    if def_disk_in_root == 'y'
    then
      echo -n "Текущий диск будет вхоить в систему..."
    else
      echo -n "Текущий диск не будет вхоить в систему..."
    fi
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

echo -n "Enter RAID level(1,2): "
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
