#!/usr/bin/env python

from ovirtsdk.api import API
from ovirtsdk.xml import params
import time

#===   variables   ===
#-- RHEVM connection
URL      = "https://RHEVM.FQDN/api"
USERNAME = "admin@internal"
PASSWORD = "PASSWORD"
CA_FILE  = "/path/to/ca.crt"

#-- VM parameters
VM_NAME      = "vm_name"
CLUSTER_NAME = "cluster_name"
SOCKETS      = 1
CORES        = 1
MEMORY_SZ    = 1  # GiB
DISK_SZ      = 35 # GiB
STG_DOMAIN   = "data_domain"
NIC_NAME     = "nic1"
NET_NAME     = "net_name"
IP_ADDR      = "192.168.0.1"
NETMASK      = "255.255.255.0"
GATEWAY      = "192.168.0.254"
DNS_SERVERS  = ""
DNS_DOMAIN   = ""

#-- Units
GiB = 2**30
#=== end variables ===

#===   functions   ===
def wait_vmstate(vm_name, state):
    """
    Polls a machine for a given
    state before to continue

    vm_name (string) : name of the machine to wait for
    state   (string) : state to wait for
    """
    while api.vms.get(vm_name).status.state != state:
        time.sleep(1)

def wait_diskstate(disk_name, state):
    """
    Polls a disk for a given
    state before to continue

    disk_name (string) : name of the disk to wait for
    state     (string) : state to wait for
    """
    while api.disks.get(disk_name).status.state != state:
        time.sleep(1)
#=== end functions ===

#-- Connection to the API
api = API(url      = URL,
          username = USERNAME,
          password = PASSWORD,
          ca_file  = CA_FILE)

#-- Creation of the VM
cpu_params = params.CPU(topology = params.CpuTopology(sockets = SOCKETS,
                                                      cores   = CORES))

api.vms.add(params.VM(name     = VM_NAME,
                      type_    = "server",
                      cluster  = api.clusters.get(CLUSTER_NAME),
                      template = api.templates.get("Blank"),
                      cpu      = cpu_params,
                      memory   = MEMORY_SZ * GiB,
                      display  = params.Display(type_ = "SPICE")))

#-- Wait for the creation to complete
wait_vmstate(VM_NAME, "down")

#-- Get the VM object and attach disk and network
vm = api.vms.get(VM_NAME)
stg_domain = api.storagedomains.get(STG_DOMAIN)
stg_parms = params.StorageDomains(storage_domain = [stg_domain])
DISK_NAME = "{0}_disk1".format(VM_NAME)
#-- Boot disk
vm.disks.add(params.Disk(name            = DISK_NAME,
                         storage_domains = stg_parms,
                         size            = DISK_SZ * GiB,
                         status          = None,
                         interface       = 'virtio',
                         format          = 'cow',
                         sparse          = True,
                         bootable        = True))
#-- Boot NIC
vm.nics.add(params.NIC(name      = NIC_NAME,
                       network   = params.Network(name = NET_NAME),
                       interface = 'virtio'))
boot_if = vm.nics.get(NIC_NAME).mac.address

#-- Define the installation boot command line
ks = "http://172.26.97.204:81/necker/virtual/{0}/main.ks".format(VM_NAME)
boot_params = {"ks":       ks,
               "ksdevice": boot_if,
               #"hostname": "{0}.{1}".format(VM_NAME, DNS_DOMAIN),
               #"dns":      DNS_SERVERS,
               "ip":       IP_ADDR,
               "netmask":  NETMASK,
               "gateway":  GATEWAY}
kernel = "iso://rhel-server-6.6-x86_64-vmlinuz"
initrd = "iso://rhel-server-6.6-x86_64-initrd.img"
cmdline = " ".join(map("{0[0]}={0[1]}".format, boot_params.iteritems()))
vm.set_os(params.OperatingSystem(kernel  = kernel,
                                 initrd  = initrd,
                                 cmdline = cmdline))
vm.update()

#-- Wait for the attachments to complete
#time.sleep(20) # FIXME : wait for disk state to be OK
wait_diskstate(DISK_NAME, 'OK')
#-- Start the VM and let the install proceed
vm.start()

#-- The kickstart should specify a poweroff directive
#-- so the VM does not install again at restart
#-- Wait for machine to power off
wait_vmstate(VM_NAME, "down")
#-- Remove boot parameters
vm.set_os(params.OperatingSystem(kernel = '', initrd = '', cmdline = ''))
vm.update()
#-- Start the VM after the installation
vm.start()
api.disconnect()
