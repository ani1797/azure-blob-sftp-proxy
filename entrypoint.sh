#!/usr/bin/env bash

# Creating Ramdisk
mkdir /mnt/ramdisk
mount -t tmpfs -o size=10g tmpfs /mnt/ramdisk

# Creating BlobFuse connection to Storage Drive
blobfuse ${STORAGE_DRIVE} --container-name=${AZURE_STORAGE_CONTAINER_NAME} --tmp-path=/mnt/ramdisk \
  -o attr_timeout=240 -o entry_timeout=240 \
  -o negative_timeout=120 --log-level=LOG_DEBUG \
  -o allow_other -o uid=${SFTP_UID} -o gid=${SFTP_GID} \
  --file-cache-timeout-in-seconds=120

if [[ $? == 0 ]]; then
  /etc/init.d/ssh start > /dev/null
  exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
else
  exit
fi
