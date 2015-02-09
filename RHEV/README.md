# Tools for RHEV
## RHEVM Backup
The script `backup_rhev-m.sh` is tested on :
* RHEV 3.4
It is intended to be run on a periodic basis by putting it into
`/etc/cron.{daily,weekly,monthly}`. It may be necessary to adapt the variable
`BACKUP_DIR` for it to point to a partition with enough disk space.
The script keeps 2 backups : the *current* (last) and the *previous* one. At
each run, the *current* is moved to become the *previous* and a new *current*
is created.
