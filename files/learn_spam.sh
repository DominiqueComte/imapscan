#! /bin/bash

LOCKFILE=/var/spamassassin/scan_lock
while [ -f "${LOCKFILE}" ] ; do
  echo "Pausing until lock file disappears."
  sleep 5
done
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
file="${HOME}/accounts/imap_accounts_learn.txt"
if [ -f ${file} ]; then
  while read -r line
  do
    # ignore lines commented with #
    [[ "${line}" =~ ^#.*$ ]] && continue
    IFS=$'\t' read -r -a account <<< "${line}"
    # to debug parsing of input file, uncomment next line
    #printf ">[%s]\n" "${account[@]}"
    IFS=${OLD_IFS}
    echo "learning ${account[1]}/${account[4]}"
    until /usr/local/bin/isbg.py --noninteractive \
      --imaphost ${account[0]} --imapuser ${account[1]}  --imappasswd ${account[2]} \
      --learnspambox ${account[3]} \
      --learnhambox ${account[4]} \
      --teachonly
    do
      (>&2 echo "isbg failed, retrying...")
    done
    echo "finished learning from ${account[1]}/${account[4]}"
  done < "$file"
  echo "EOS"
fi
