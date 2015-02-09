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

## Automatic VM deployment w/o PXE
The script `virt-install-rhev.py` is tested on :
* RHEV 3.4

The script allows fully automated **RHEL guests** installation on RHEV without
PXE by simply using kickstart and the API of RHEV.

For now, the script behaviour car be modified by editing in-line variables
content. Further improvement would be to make default values available through
a configuration file and to make these variables editable at runtime through
command line options.

Requirements for the running host :
- Package `rhevm-sdk-python` installed
- HTTPS access to the RHEV-M
- RHEV-M's Certificate Authority locally accessible

Other requirements :
- The ISO domain provides pxelinux files (from the RHEL DVD)
- Kickstart files accessible through the network
- `poweroff` directive in the kickstart file

This tool was inspired by this page : http://www.kernel-panic.it/linux/rhev/
