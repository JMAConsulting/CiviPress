#!/bin/bash

# {{ ansible_managed }}

# Based on:
# https://raw.githubusercontent.com/omega8cc/boa/master/aegir/tools/system/weekly.sh

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
SHELL=/bin/bash

check_root() {
  if [ `whoami` = "root" ]; then
    ionice -c2 -n7 -p $$
    renice 19 -p $$ >/dev/null
  else
    echo "ERROR: This script should be ran as a root user"
    exit 1
  fi
}
check_root

###-------------SYSTEM-----------------###

count() {
  User="/var/aegir"

  for Site in `find /var/aegir/config/server_master/*/vhost.d -maxdepth 1 -mindepth 1 -type f | sort`; do
    Dom=$(echo $Site | cut -d'/' -f8 | awk '{ print $1}' 2>&1)

    _DEV_URL=NO
    case ${Dom} in
      *.dev.*) _DEV_URL=YES ;;
      *.temp.*) _DEV_URL=YES ;;
      *.tmp.*) _DEV_URL=YES ;;
      *.test.*) _DEV_URL=YES ;;
      *.staging.*) _DEV_URL=YES ;;
      *-dev.*) _DEV_URL=YES ;;
      dev-.*) _DEV_URL=YES ;;
      test-.*) _DEV_URL=YES ;;
      *.symbiodev.xyz) _DEV_URL=YES ;;
      *)
      ;;
    esac
    if [ -e "${User}/.drush/${Dom}.alias.drushrc.php" ]; then
      #echo "${_THIS_U},${Dom},drushrc-exists"
      Dir=$(cat ${User}/.drush/${Dom}.alias.drushrc.php \
        | grep "site_path'" \
        | cut -d: -f2 \
        | awk '{ print $3}' \
        | sed "s/[\,']//g" 2>&1)
      Plr=$(cat ${User}/.drush/${Dom}.alias.drushrc.php \
        | grep "root'" \
        | cut -d: -f2 \
        | awk '{ print $3}' \
        | sed "s/[\,']//g" 2>&1)

      if [ -e "${Dir}/drushrc.php" ] \
        && [ -e "${Dir}/files" ] \
        && [ -e "${Dir}/private" ] \
        && [ -e "${Dir}/modules" ] \
        && [ ! -e "${Plr}/profiles/hostmaster" ]; then
        #echo "${_THIS_U},${Dom},sitedir-exists"
        Dat=$(cat ${Dir}/drushrc.php \
          | grep "options\['db_name'\] = " \
          | cut -d: -f2 \
          | awk '{ print $3}' \
          | sed "s/[\,';]//g" 2>&1)
        #echo Dat is ${Dat}
        if [ ! -z "${Dat}" ] && [ -e "${Dir}" ]; then
          if [ -L "${Dir}/files" ] || [ -L "${Dir}/private" ]; then
            DirSize=$(du -L -s ${Dir} 2>&1)
          else
            DirSize=$(du -s ${Dir} 2>&1)
          fi
          DirSize=$(echo "${DirSize}" \
            | cut -d'/' -f1 \
            | awk '{ print $1}' \
            | sed "s/[\/\s+]//g" 2>&1)
          SumDir=$(( SumDir + DirSize ))
          if [ "${_DEV_URL}" = "YES" ]; then
            echo "${_THIS_U},${Dom},DirSize:${DirSize},skip"
          else
            echo "${_THIS_U},${Dom},DirSize:${DirSize}"
          fi
        fi
        if [ ! -z "${Dat}" ] && [ -e "/var/lib/mysql/${Dat}" ]; then
          DatSize=$(du -s /var/lib/mysql/${Dat} 2>&1)
          DatSize=$(echo "${DatSize}" \
            | cut -d'/' -f1 \
            | awk '{ print $1}' \
            | sed "s/[\/\s+]//g" 2>&1)
          if [ "${_DEV_URL}" = "YES" ]; then
            SkipDt=$(( SkipDt + DatSize ))
            echo "${_THIS_U},${Dom},DatSize:${DatSize}:${Dat},skip"
          else
            SumDat=$(( SumDat + DatSize ))
            echo "${_THIS_U},${Dom},DatSize:${DatSize}:${Dat}"
          fi
        else
          # Database ${Dat} for ${Dom} does not exist
          # Assumed to be hosted on another server
          echo "${_THIS_U},${Dom},DatSize:0:${Dat}"
        fi

        if [ "${_DEV_URL}" = "NO" ]; then
          CiviStats=$(sudo -i -u aegir drush @${Dom} provision-symbiotic-civicrm-stats 2>/dev/null)
          CiviContact=$(echo $CiviStats | cut -d ',' -f 1)
          CiviActivity=$(echo $CiviStats | cut -d ',' -f 2)
          CiviContribute=$(echo $CiviStats | cut -d ',' -f 3)
          CiviMember=$(echo $CiviStats | cut -d ',' -f 4)
          CiviMail=$(echo $CiviStats | cut -d ',' -f 5)
          CiviSms=$(echo $CiviStats | cut -d ',' -f 6)
          CiviCase=$(echo $CiviStats | cut -d ',' -f 7)
          CiviEvent=$(echo $CiviStats | cut -d ',' -f 8)
          CiviParticipant=$(echo $CiviStats | cut -d ',' -f 9)
          CiviPaymentProcessors=$(echo $CiviStats | cut -d ',' -f 10)
          CiviLanguages=$(echo $CiviStats | cut -d ',' -f 11)
          LastLogin=$(echo $CiviStats | cut -d ',' -f 12)

          echo "${_THIS_U},${Dom},CiviContact:${CiviContact}"
          echo "${_THIS_U},${Dom},CiviActivity:${CiviActivity}"
          echo "${_THIS_U},${Dom},CiviContribute:${CiviContact}"
          echo "${_THIS_U},${Dom},CiviMember:${CiviMember}"
          echo "${_THIS_U},${Dom},CiviMail:${CiviMail}"
          echo "${_THIS_U},${Dom},CiviSms:${CiviSms}"
          echo "${_THIS_U},${Dom},CiviCase:${CiviCase}"
          echo "${_THIS_U},${Dom},CiviEvent:${CiviEvent}"
          echo "${_THIS_U},${Dom},CiviParticipant:${CiviParticipant}"
          echo "${_THIS_U},${Dom},CiviPaymentProcessors:${CiviPaymentProcessors}"
          echo "${_THIS_U},${Dom},CiviLanguages:${CiviLanguages}"
          echo "${_THIS_U},${Dom},LastLogin:${LastLogin}"
        fi
      fi
    fi
  done
}

action() {
  SumDir=0
  SumDat=0
  SkipDt=0
  HomSiz=0
  HxmSiz=0
  HqmSiz=0

  User="/var/aegir"

  _THIS_U='aegir'
  _THIS_HM_SITE=$(cat /var/aegir/.drush/hostmaster.alias.drushrc.php \
    | grep "site_path'" \
    | cut -d: -f2 \
    | awk '{ print $3}' \
    | sed "s/[\,']//g" 2>&1)
  _THIS_HM_PLR=$(cat /var/aegir/.drush/hostmaster.alias.drushrc.php \
    | grep "root'" \
    | cut -d: -f2 \
    | awk '{ print $3}' \
    | sed "s/[\,']//g" 2>&1)

  _DOW=$(date +%u 2>&1)
  _DOW=${_DOW//[^1-7]/}
  count
}

###--------------------###
_NOW=$(date +"%Y%m%d%H%M" 2>&1)
_NOWDAY=$(date +"%Y%m%d" 2>&1)
_CHECK_HOST=$(hostname -f 2>&1)
_VM_TEST=$(uname -a 2>&1)
_VMFAMILY="KVM"

mkdir -p /var/log/aegir

echo "# $_NOW" > /var/log/aegir/usage.log
echo "# $_CHECK_HOST" >> /var/log/aegir/usage.log

action >> /var/log/aegir/usage.log 2>&1
cp /var/log/aegir/usage.log /var/log/aegir/usage.$_NOWDAY.log
chmod 0644 /var/log/aegir/usage.log
chmod 0644 /var/log/aegir/usage.$_NOWDAY.log
exit 0
