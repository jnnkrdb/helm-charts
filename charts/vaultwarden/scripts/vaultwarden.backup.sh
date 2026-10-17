#!/bin/sh

# Creating a Backup of Vaultwarden Data
# the source directory can be configured via env vars
# if not set, then the default /data will be used

_SOURCE="${VAULTWARDEN_DATA_DIR:-/data}"
_DESTINATION="${VAULTWARDEN_BACKUP_DIR:-/backup}"
_VERSION="${VAULTWARDEN_VERSION:-latest}"

# print the configs
echo ""
echo "#########################################"
echo "################ Configs ################"
echo "#########################################"
echo "               date : $(date +"%Y-%m-%d")"
echo "               time : $(date +"%H-%M")"
echo "             source : ${_SOURCE}"
echo "        destination : ${_DESTINATION}"
echo "vaultwarden version : ${_VERSION}"
echo "#########################################"

echo "Current state of existing backups:"
ls -lah ${_DESTINATION}

_current="vw_${_VERSION}_bak_$(date +"%Y-%m-%d")"
# _current_bak="${_DESTINATION}/${_current}.tar.gz"
# _current_sha="${_current_bak}.sha256"

# create the backup plus the sha256 sum
_tmp_bak="${_DESTINATION}/tmp.tar.gz"
tar -czvf "${_tmp_bak}" "${_SOURCE}"
sha256sum "${_tmp_bak}" > ${_tmp_bak}.sha256
# results in following
# /backup
# ├─ vw_1.36.0_bak_2025-01-31.tar.gz
# ├─ vw_1.36.0_bak_2025-01-31.tar.gz.sha256
# ├─ latest.tar.gz.info
# ├─ latest.tar.gz
# ├─ latest.tar.gz.sha256
# ├─ tmp.tar.gz           <- this one new
# └─ tmp.tar.gz.sha256    <- this one new

# check whether there is already an latest backup or not
_latest_bak="${_DESTINATION}/latest.tar.gz"
if [ ! -f "${_latest_bak}" ]; then
  echo "Currently there is no existing latest backup. Creating..."

  # create the new latest backup from the tmp backup files
  mv ${_DESTINATION}/tmp.tar.gz ${_latest_bak}
  mv ${_DESTINATION}/tmp.tar.gz.sha256 ${_latest_bak}.sha256 
  echo "${_current}" > ${_latest_bak}.info
else
  if [ "$(cat ${_tmp_bak}.sha256)" = "$(cat ${_latest_bak}.sha256)" ]; then
    echo "The Backups Sha256 Sums do not differ, therefore there shouldn't be any differences."
    rm -fR ${_tmp_bak} ${_tmp_bak}.sha256
    exit 0
  else
    echo "The Backups Sha256 Sums do differ, therefore we have to create a new backup file +sha-sum + info-file."
    
    # move the current latest into the specified state
    _latest_info="$(cat ${_latest_bak}.info)"
    mv ${_latest_bak} ${_DESTINATION}/${_latest_info}.tar.gz 
    mv ${_latest_bak}.sha256 ${_DESTINATION}/${_latest_info}.tar.gz.sha256 

    # create the new latest backup from the tmp backup files
    mv ${_DESTINATION}/tmp.tar.gz ${_latest_bak} 
    mv ${_DESTINATION}/tmp.tar.gz.sha256 ${_latest_bak}.sha256 
    echo "${_current}" > ${_latest_bak}.info
  fi
fi
