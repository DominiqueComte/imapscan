Docker container that uses [isbg](https://github.com/dc55028/isbg) and [imapfilter](https://github.com/lefcha/imapfilter) to filter out spam from a remote IMAP server.

Docker hub link: https://hub.docker.com/r/domcomte/imapscan/

[![](https://images.microbadger.com/badges/image/domcomte/imapscan.svg)] [![](https://images.microbadger.com/badges/version/domcomte/imapscan.svg)]

Configuration: There are 3 volumes, their content is initialized during container startup:

/var/spamassassin : holds the SpamAssassin data files, to keep them between container resets.
/root/.imapfilter : holds the ImapFilter configuration script.
/root/accounts : holds the IMAP accounts configuration.
To configure your IMAP accounts, edit the accounts_imap.txt and imap_accounts_learn.txt in the /root/accounts directory in the container, or in the /root/accounts volume on the host. They are tab-separated files, and the first line has the field names.

In both files, the "junk" field is where the Spam folder is, and the last field is the directory you want to scan, either to learn spam or to scan for spam.

The container runs a learning process on startup, so do not leave a configuration with a huge email directory active if you want the container to start in a reasonnable time.
