This script is designed to create and configure virtual machines running Apple operating systems, hosted on a VMware ESXi server running on Apple hardware. The script assumes that the virtual machines are built using copied VMDK disk files.

Script is designed to be stored on an ESXi datastore and run from the ESXi server's command line interface.

Usage: `/path/to/esxi_macos_vm_creation.sh -n -d -c -h -i -o -r -s -v -p`

Options:

* **-n**: Name of VM (required)
* **-d**: Location of a VMDK disk file (required).  Location must be in this format - `/vmfs/volumes/datastore_number_here/path/to/vmdk_file.vmdk`
* **-c**: Number of virtual CPUs
* **-h**: VMware Hardware Version
* **-i**: Location of an ISO image. Location must be in this format - `/vmfs/volumes/datastore_number_here/path/to/iso_file.iso`
* **-o**: Apple OS version
* **-r**: RAM size in MB
* **-s**: Disk size in GB
* **-v**: VNC port between 5900 and 5909
* **-p**: VNC password. Maximum password length is eight characters.

**Examples:**

To set up a VM specifying only the VM name and VMDK location:

`/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk`

To set up a VM using a name with spaces and/or special characters, add quotation marks to the VM name:
 
`/path/to/esxi_macos_vm_creation.sh -n "VM's Name Goes Here!" -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk`


Other flags can be added as needed:

To set up a VM and add more CPUs:

`/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -c 4 -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk`

 To set up a VM and enable VNC on port 5901 with the password set to the word `password`:

`/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk -v 5901 -p password`

To set up a VM named `MacOS VM 10.12` using a VDMK stored on `/vmfs/volumes/datastore1/template` and named `macos-vm.vmdk` with 4 CPUs, 8 GBs of RAM, a 52 GB hard drive, set to HW Version 13, guest OS set to macOS Sierra and VNC enabled on port 5902 with the VNC password set to the word `password`:

`/path/to/esxi_macos_vm_creation.sh -n "MacOS VM 10.12" -d /vmfs/volumes/datastore1/template/macos-vm.vmdk -c 4 -r 8192 -s 52 -h 13 -o darwin16-64 -v 5902 -p password`



Based on [Tamas Piros](https://github.com/tpiros)'s auto-create: [https://github.com/tpiros/auto-create](https://github.com/tpiros/auto-create)

Blog post: [http://www.tamas.io/automatic-virtual-machine-creation-from-command-line-in-vmwares-esxi/](http://www.tamas.io/automatic-virtual-machine-creation-from-command-line-in-vmwares-esxi/)