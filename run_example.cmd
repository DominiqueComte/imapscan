setlocal
set IMAGE_VERSION=0.12
set CONTAINER_VOLUMES_DIR=d:/docker_volumes/imapscan

docker run -d --name imapscan_%IMAGE_VERSION% -v %CONTAINER_VOLUMES_DIR%/spamassassin:/var/spamassassin -v %CONTAINER_VOLUMES_DIR%/imapfilter:/root/.imapfilter -v %CONTAINER_VOLUMES_DIR%/accounts:/root/accounts domcomte/imapscan:%IMAGE_VERSION%
