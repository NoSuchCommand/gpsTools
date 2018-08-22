# Utility scripts for OpenShift

## newpv

Helper script to create a new NFS backed PersistentVolume on OpenShift

### Pre-requisites

The script:
  - is mainly intended to work on RHEL 6.7 and newer (and corresponding CentOS
    releases)
  - must be executed as the super-user
  - must be executed on the NFS server itself
  - must be able to silently connect as OpenShift's `system:admin` on
    project `default` (system-wide or root's `kubeconfig` file can suffice)

General considerations:
  - The NFS service must be running
  - SELinux must be enabled
  - An LVM Volumes Group named `exports` must exist

### TODO

  - The script currently does not rollback anything in case of a fatal error
  - Might be a good idea to allow the user to specify the name of the VG
  - Get a better understanding of which one of the node or the container is
    actually accessing the NFS share in order to enhance the export ACL
  - Allow the user to specify the hostname of the NFS server instead of the
    system's FQDN, which may be a default
