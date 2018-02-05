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
set -o pipefail
OLD_IFS=${IFS}
file=${HOME}/accounts/imap_accounts.txt
if [ -f "${file}" ]; then
  while read -r line
  do
    # ignore lines commented with #
    [[ "${line}" =~ ^#.*$ ]] && continue
    IFS=$'\t' read -r -a account <<< "${line}"
    # to debug parsing of input file, uncomment next line
    #printf ">[%s]\n" "${account[@]}"
    IFS=${OLD_IFS}
    echo "scanning spam in ${account[1]}/${account[3]} and ham in ${account[1]}/${account[4]}"
    until /usr/local/bin/isbg.py --noninteractive --flag --spamc \
        --imaphost ${account[0]} --imapuser "${account[1]}"  --imappasswd "${account[2]}" \
        --spaminbox "${account[3]}" \
        --imapinbox "${account[4]}"
    do
        (>&2 echo "isbg failed, retrying...")
    done
    echo "scanning of spam in ${account[1]}/${account[3]} and ham in ${account[1]}/${account[4]} done"
  done < "$file"
  until imapfilter
  do
    echo "imapfilter failed, retrying..."
  done
  echo "EOS"
fi
