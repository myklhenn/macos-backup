#!/bin/bash

# This script utilizes rsync (in a "pull" configuration) to backup the user
# folder (/Users/<user>/) of the specified macOS host and user to a server.
#
# Expected config variables (loaded from shell environment or config file):
#
# BACKUP_CLIENT_HOSTNAME -- hostname of backup server (as used in ssh config)
# BACKUP_CLIENT_USERNAME -- name of user used to connect to backup client
# BACKUP_PATH_ON_SERVER -- where backup, filter file and log file are located

RSYNC_PATH=/usr/local/bin/rsync
SSH_PATH=/usr/bin/ssh

die() {
  echo "$*" >&2 && exit 1
}

show_help() {
  echo "Usage: $0 [-c config_file] [-o rsync_opts]"
  echo "  -c, --config=FILE    file to load config from"
  echo "  -o, --options=OPTS   additional options to pass to rsync"
}

arg_missing() {
  die "ERROR: \"$*\" requires an argument."
}

arg_ignored() {
  echo "WARN: Unknown option (ignored): $1" >&2
}

validate_arg() {
  if [ "$2" ]; then
    return 0
  else
    arg_missing $1
  fi
}

check_config_var() {
  if [ -z "$2" ]; then
    echo "ERROR: Required config variable $1 missing." >&2
    BAD_CONFIG=1
  fi
}

RSYNC_OPTS=
while :; do
  case $1 in
  -h | -\? | --help)
    show_help && exit
    ;;
  -c | --config)
    validate_arg $1 $2 && source $2 && shift
    ;;
  --config=?*)
    source ${1#*=}
    ;;
  --config=)
    arg_missing $1
    ;;
  -o | --options)
    validate_arg $1 $2 && RSYNC_OPTS=$2 && shift
    ;;
  --options=?*)
    RSYNC_OPTS=${1#*=}
    ;;
  --options=)
    arg_missing $1
    ;;
  --)
    shift && break
    ;;
  -?*)
    arg_ignored $1
    ;;
  *)
    break
    ;;
  esac
  shift
done

BAD_CONFIG=0
check_config_var "BACKUP_CLIENT_HOSTNAME" $BACKUP_CLIENT_HOSTNAME
check_config_var "BACKUP_CLIENT_USERNAME" $BACKUP_CLIENT_USERNAME
check_config_var "BACKUP_PATH_ON_SERVER" $BACKUP_PATH_ON_SERVER

if [ $BAD_CONFIG -eq 1 ]; then
  die 'Set in your environment or load from a file using the "--config" option.'
fi

$RSYNC_PATH $RSYNC_OPTS \
  --verbose \
  --itemize-changes \
  --stats \
  --archive \
  --delete \
  --delay-updates \
  --rsh=$SSH_PATH \
  --include-from="$BACKUP_PATH_ON_SERVER/rsync-filter.txt" \
  --log-file="$BACKUP_PATH_ON_SERVER/rsync-log.txt" \
  $BACKUP_CLIENT_HOSTNAME:/Users/$BACKUP_CLIENT_USERNAME/ \
  $BACKUP_PATH_ON_SERVER/$BACKUP_CLIENT_USERNAME/
