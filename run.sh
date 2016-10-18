#!/bin/bash
set -euo pipefail

if [[ "$PLEX_MEDIA_SERVER_USER_UID" == "-1" ]]; then
    echo "--> Set PLEX_MEDIA_SERVER_USER_UID to the UID desired for the plex user"
    exit 1
fi
/usr/sbin/usermod -u $PLEX_MEDIA_SERVER_USER_UID $PLEX_MEDIA_SERVER_USER
chown $PLEX_MEDIA_SERVER_USER_UID "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"

if [ -f /etc/default/locale ]; then
  export LANG="`cat /etc/default/locale|awk -F '=' '/LANG=/{print $2}'|sed 's/"//g'`"
  export LC_ALL="$LANG"
fi

export PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
export LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}"
export TMPDIR="${PLEX_MEDIA_SERVER_TMPDIR}"

echo $PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS $PLEX_MEDIA_SERVER_MAX_STACK_SIZE $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR

ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE

(cd /usr/lib/plexmediaserver; ./Plex\ Media\ Server)
