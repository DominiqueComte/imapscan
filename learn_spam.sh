#! /bin/bash

while [ -f "/var/spamassassin/learn_lock" ] ; do
  logger "Pausing until lock file disappears."
  sleep 5
done

function cleanup {
  rm /var/spamassassin/learn_lock
}
trap cleanup EXIT

touch /var/spamassassin/learn_lock

set -f
OLD_IFS=${IFS}
file="${HOME}/accounts/imap_accounts_learn.txt"
if [ -f ${file} ]; then
  while read -r line; do
    # ignore lines commented with #
    [[ "${line}" =~ ^#.*$ ]] && continue
    IFS='	' read -r -a account <<< "${line}"
    # to debug parsing of input file, uncomment next line
    #printf ">[%s]\n" "${account[@]}"
    IFS=${OLD_IFS}
    logger "learning ${account[1]}/${account[4]}"
    /usr/local/bin/isbg.py --noninteractive \
      --imaphost ${account[0]} --imapuser ${account[1]}  --imappasswd ${account[2]} \
      --learnspambox ${account[3]} \
      --learnhambox ${account[4]} \
      --teachonly 2>&1 | logger
    logger "finished learning from ${account[1]}/${account[4]}"
  done < "$file"
fi
