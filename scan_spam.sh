#! /bin/bash

LOCKFILE=/var/spamassassin/scan_lock
[ -f "${LOCKFILE}" ] && exit
STARTED=0

function cleanup {
  if [ $STARTED -eq 1 ]; then
    rm "${LOCKFILE}"
  fi
}
trap cleanup EXIT

touch "${LOCKFILE}"
STARTED=1
set -f
OLD_IFS=${IFS}
file=${HOME}/accounts/imap_accounts.txt
if [ -f "${file}" ]; then
  while read -r line; do
    # ignore lines commented with #
    [[ "${line}" =~ ^#.*$ ]] && continue
		IFS=$'\t' read -r -a account <<< "${line}"
    # to debug parsing of input file, uncomment next line
    #printf ">[%s]\n" "${account[@]}"
    IFS=${OLD_IFS}
    logger "scanning ${account[1]}/${account[4]}"
    /usr/local/bin/isbg.py --noninteractive --flag \
      --imaphost ${account[0]} --imapuser "${account[1]}"  --imappasswd "${account[2]}" \
      --spaminbox "${account[3]}" \
      --imapinbox "${account[4]}" 2>&1 | logger
    logger "scanning of ${account[1]}/${account[4]} done"
  done < "$file"
  imapfilter | logger
fi
