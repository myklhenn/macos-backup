# macos-backup

A bash script to back up a macOS user's files to a server using [rsync].

## Usage

```
macos-backup.sh [-c config_file] [-o rsync_opts]
```

Specify additional options to pass to `rsync` (as run in this script):

`-o, --options=OPTS`

Specify a file to load configuration parameters from:

`-c, --config=FILE`

## Config

Expected configuration variables (provided either in your shell's environment, or in a config file):

```
# hostname of backup server (as used in ssh config)
BACKUP_SERVER_HOSTNAME=

# name of user used to connect to backup client
BACKUP_CLIENT_USERNAME=

#  where backup, filter file and log file are stored
BACKUP_SERVER_PATH=
```
