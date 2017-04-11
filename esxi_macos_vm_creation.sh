#!/bin/sh

# Parameters: 
#
# Virtual machine name (required)
# CPU (number of cores)
# VMDK (location of VMDK file, required) 
# RAM (memory size in MB)
# Hard Drive size (in GB)
# Hardware Version
# ISO (Location of ISO image, optional)
# Apple OS version
# VNC port
# VNC password
# 
# Default values: CPU: 2, RAM: 4096, Hard drive size: 40 GB, Hardware Version: 11, ISO: 'blank', OS version: darwin14-64
#
# Usage:
# When using the script, command should look something like this:
#
# /vmfs/volumes/datastore_number_here/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk
#
# To set up a VM using a name with spaces and/or special characters, add quotation marks to the VM name:
# 
# /vmfs/volumes/datastore_number_here/path/to/esxi_macos_vm_creation.sh -n "VM's Name Goes Here!" -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk
#
# Other flags can be added as needed:
#
# To set up a VM and add more CPUs:
#
# /vmfs/volumes/datastore_number_here/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -c 4 -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk
#
# To set up a VM and enable VNC on port 5901 with the password of "password":
#
# /vmfs/volumes/datastore_number_here/path/to/esxi_macos_vm_creation.sh -n VM_Name_Goes_Here -d /vmfs/volumes/datastore_number_here/path/to/filename_here.vmdk -v 5901 -p password
#
# To set up a VM named "MacOS VM 10.12" (no quotes) using a VDMK stored on /vmfs/volumes/datastore1/template and named "macos-vm.vmdk" (no quotes) with 4 CPUs 
# 8 GBs of RAM, a 52 GB hard drive, VMware Hardware Version set to HW Version 13, guest OS set to macOS Sierra, and VNC enabled on port 5902 with the VNC password set to the word "password" (no quotes)
#
# /vmfs/volumes/datastore_number_here/path/to/esxi_macos_vm_creation.sh -n "MacOS VM 10.12" -d /vmfs/volumes/datastore1/template/macos-vm.vmdk -c 4 -r 8192 -s 52 -h 13 -o darwin16-64 -v 5902 -p password

phelp() {
	echo ""
	echo "Usage: ./esxi_macos_vm_creation.sh options: -n -d -c -h -i -o -r -s -v -p"
	echo ""
	echo "n: Name of VM (required). If using a name with spaces and/or special characters, add quotation marks to the VM name."
	echo "c: Number of virtual CPUs. Default number is two."
	echo "d: location of a VMDK disk file (required). Location must be in this format - /vmfs/volumes/datastore_number_here/path/to/vmdk_file.vmdk"
	echo "h: VMware hardware version. ESXi 5.5 supports up to HW 10, ESXi 6.x supports up to HW 11 and ESXi 6.5 supports up to HW 13."
	echo "i: Location of an ISO image. Location must be in this format - /vmfs/volumes/datastore_number_here/path/to/iso_file.iso"
	echo "o: Mac operating system version. Default is set to darwin14, which reports the guest OS as OS X Yosemite."
	echo ""
	echo "VMware guest OS values for the following versions of OS X and macOS:"
	echo ""
	echo "Mac OS 10.7 - darwin11-64"
	echo "OS 10.8 - darwin12-64"
	echo "OS 10.9 - darwin13-64"
	echo "OS 10.10 - darwin14-64"
	echo "OS 10.11 - darwin15-64"
	echo "macOS 10.12 - darwin16-64"
	echo ""
	echo "r: RAM size in MB. Default number is 4096, for 4 GBs of memory."
	echo "s: Disk size in GB. Default size is 40 GB. You can specify if you want it to be larger."
	echo "v: VNC port is between 5900 and 5909  (required if also using the -p option)"
	echo "p: VNC password (required if also using the -v option). Maximum password length is eight characters."
	echo ""
	echo "Default script values: ESXi datastore location: /vmfs/volumes/datastore1, CPU: 2, RAM: 4096MB, Hard drive size: 40GB, Guest OS: darwin14-64, Hardware Version: 11"
	echo ""
}

# Set datastore location

DATASTORE="/vmfs/volumes/datastore1"

# Default variables. These values are overriden if alternate values
# are enabled by the script's available options.

CPU=2
RAM=4096
SIZE=40
ISO=""
OSVERS="darwin14-64"
HWVERS="11"
FLAG=true
ERR=false

# Error checking:
#
# The NAME has to be entered (i.e. the $NAME variable cannot be blank.)
# The CPU has to be an integer and it has to be between 1 and 32. Modify the if statement if you want to give more than 32 cores to your Virtual Machine, and also email me pls :)
# The VMDK has to have its location provided and we are checking for an actual .vmdk extension
# RAM has to be an integer and has to be greater than 0.
# The hard drive size has to be an integer and has to be greater than 0.
# The hardware version has to be an integer and has to be greater than 0
# If the ISO parameter is added, we are checking for an actual .iso extension
# If the VNC port parameter is used, it has to be an integer and has to be between 5900 and 5909. 
# Note: If needed, this port limitation can be changed by editing the script.
# If the VNC password parameter is used, a password must be entered.

while getopts n:c:d:h:i:o:r:s:v:p: option
do
        case $option in
                n)
					NAME=${OPTARG};
					FLAG=false;
					if [ -z "${NAME}" ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a VM name."
					fi
					;;
                c)
					CPU=${OPTARG}
					if [ `echo "${CPU}" | egrep "^-?[0-9]+$"` ]; then
						if [ "${CPU}" -le "0" ] || [ "${CPU}" -ge "32" ]; then
							ERR=true
							MSG="$MSG | The number of cores has to be between 1 and 32."
						fi
					else
						ERR=true
						MSG="$MSG | The CPU core number has to be an integer."
					fi
					;;
				d)
					VMDK=${OPTARG}
					FLAG=false;
					if [ -z "${VMDK}" ]; then
						ERR=true
						MSG="$MSG | Please provide a path to a VMDK file."
					fi					
					if [ ! `echo "${VMDK}" | egrep "^.*\.(vmdk)$"` ]; then
						ERR=true
						MSG="$MSG | The extension should be .vmdk"
					fi
					;;
                h)
					HWVERS=${OPTARG}
					if [ `echo "${HWVERS}" | egrep "^-?[0-9]+$"` ]; then
						if [ "${HWVERS}" -eq "${HWVERS}" ] && [ "${HWVERS}" -lt "10" ]; then
							ERR=true
							MSG="$MSG | Please assign a value of 10 or more for the hardware version. ESXi 5.5 supports up to HW 10, ESXi 6.0.x supports up to HW 11 and ESXi 6.5 supports up to HW 13."
						fi
					else
						ERR=true
						MSG="$MSG | The hardware version has to be an integer."
					fi
					;;
				i)
					ISO=${OPTARG}
					if [ ! `echo "${ISO}" | egrep "^.*\.(iso)$"` ]; then
						ERR=true
						MSG="$MSG | The extension should be .iso"
					fi
					;;
                o)
					OSVERS=${OPTARG};
					if [ -z "${OSVERS}" ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a valid OS version. darwin14-64 = OS X 10.10 Yosemite, darwin15-64 = OS X 10.11 El Capitan, and darwin16-64 = macOS 10.12 Sierra."
					fi
					;;
                r)
					RAM=${OPTARG}
					if [ `echo "${RAM}" | egrep "^-?[0-9]+$"` ]; then
						if [ "${RAM}" -le "0" ]; then
							ERR=true
							MSG="$MSG | Please assign more than 1MB memory to the VM."
						fi
					else
						ERR=true
						MSG="$MSG | The RAM size has to be an integer."
					fi
					;;
                s)
					SIZE=${OPTARG}
					if [ `echo "${SIZE}" | egrep "^-?[0-9]+$"` ]; then
						if [ "${SIZE}" -le "40" ]; then
							ERR=true
							MSG="$MSG | Please assign more than 40 GB for the hard drive size."
						fi
					else
						ERR=true
						MSG="$MSG | The hard drive size has to be an integer."
					fi
					;;
                v)
					VNCPORT=${OPTARG}
					if [ `echo "${VNCPORT}" | egrep "^-?[0-9]+$"` ]; then
						if [ "${VNCPORT}" -lt "5900" ] || [ "${VNCPORT}" -gt "5909" ]; then
							ERR=true
							MSG="$MSG | Please assign a port number for VNC between 5900 and 5909."
						fi
					else
						ERR=true
						MSG="$MSG | The VNC port has to be an integer."
					fi
					;;
                p)
					VNCPASS=${OPTARG}
					if [ -z "${VNCPASS}" ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a VNC pasword. Maximum password length is eight characters."
					fi
					;;
				\?) echo "Unknown option: -$OPTARG" >&2; phelp; exit 1;;
        		:) echo "Missing option argument for -$OPTARG" >&2; phelp; exit 1;;
        		*) echo "Unimplemented option: -$OPTARG" >&2; phelp; exit 1;;
        esac
done

if [ -z "${NAME}" ]; then
    echo ""
	echo ">> PROBLEM << : Please specify the name of the machine using the -n option. Displaying script options below."
    echo ""
	phelp
	exit 1
fi

if [ -z "${VMDK}" ]; then
    echo ""
	echo ">> PROBLEM << : Please specify the location of a VMDK disk file with the -d parameter. Location must be in this format - /vmfs/volumes/datastore_number_here/path/to/vmdk_file.vmdk. Displaying script options below."
    echo ""
	phelp
	exit 1
fi


if [ "${VNCPORT}" != "" ] && [ -z "${VNCPASS}" ]; then
    echo ""
	echo ">> PROBLEM << : Please specify a password for VNC using the -p option. Displaying script options below."
    echo ""
	phelp
	exit 1
elif [ "${VNCPASS}" != "" ] && [ -z "${VNCPORT}" ]; then
    echo ""
	echo ">> PROBLEM << : Please specify a port number for VNC using the -v option. Displaying script options below."
	echo ""
	phelp
	exit 1
fi

if [ "${VNCPORT}" != "" ] && [ "${VNCPASS}" != "" ]; then
	VNCSTATUS=TRUE
else
    VNCSTATUS=FALSE
fi

if $ERR; then
	echo $MSG
	exit 1
fi

if [ -d "${DATASTORE}"/"${NAME}" ]; then
	echo "Directory - ${NAME} already exists, can't recreate it."
	exit
fi

#Creating the folder for the Virtual Machine
mkdir -p "${DATASTORE}"/"${NAME}"

#Creating VM disk from vmdk template using vmkfstools
# Link: https://kb.vmware.com/kb/1027876
vmkfstools -i "${VMDK}" "${DATASTORE}"/"${NAME}"/"${NAME}".vmdk -d thin

# If specified size is larger than 40 GBs, resize VMDK file using vmkfstools
# Link: https://kb.vmware.com/kb/1002019
if [ "${SIZE}" -gt "40" ]; then
    vmkfstools -X "${SIZE}"g "${DATASTORE}"/"${NAME}"/"${NAME}".vmdk
fi


#Creating the config file
touch "${DATASTORE}"/"${NAME}"/"${NAME}".vmx

#writing information into the configuration file

if [ "${VNCSTATUS}" = "TRUE" ]; then

cat << EOF > "${DATASTORE}"/"${NAME}"/"${NAME}".vmx
config.version = "8"
virtualHW.version = "${HWVERS}"
vmci0.present = "TRUE"
displayName = "${NAME}"
floppy0.present = "FALSE"
numvcpus = "${CPU}"
scsi0.present = "TRUE"
scsi0.sharedBus = "none"
scsi0.virtualDev = "lsilogic"
sata0.present = "TRUE"
memsize = "${RAM}"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "${NAME}.vmdk"
scsi0:0.deviceType = "scsi-hardDisk"
sata0:1.present = "TRUE"
sata0:1.fileName = "${ISO}"
sata0:1.deviceType = "cdrom-image"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
ethernet0.virtualDev = "e1000e"
ethernet0.networkName = "VM Network"
ethernet0.addressType = "generated"
ethernet0.present = "TRUE"
usb.present = "TRUE"
guestOS = "${OSVERS}"
RemoteDisplay.vnc.enabled = "${VNCSTATUS}"
RemoteDisplay.vnc.port = "${VNCPORT}"
RemoteDisplay.vnc.key = "${VNCPASS}"
smc.present = "TRUE"
EOF

else

cat << EOF > "${DATASTORE}"/"${NAME}"/"${NAME}".vmx
config.version = "8"
virtualHW.version = "${HWVERS}"
vmci0.present = "TRUE"
displayName = "${NAME}"
floppy0.present = "FALSE"
numvcpus = "${CPU}"
scsi0.present = "TRUE"
scsi0.sharedBus = "none"
scsi0.virtualDev = "lsilogic"
sata0.present = "TRUE"
memsize = "${RAM}"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "${NAME}.vmdk"
scsi0:0.deviceType = "scsi-hardDisk"
sata0:1.present = "TRUE"
sata0:1.fileName = "${ISO}"
sata0:1.deviceType = "cdrom-image"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
ethernet0.virtualDev = "e1000e"
ethernet0.networkName = "VM Network"
ethernet0.addressType = "generated"
ethernet0.present = "TRUE"
usb.present = "TRUE"
guestOS = "${OSVERS}"
smc.present = "TRUE"
EOF

fi

#Adding Virtual Machine to VM register
MYVM=`vim-cmd solo/registervm "${DATASTORE}"/"${NAME}"/"${NAME}".vmx`
#Powering up virtual machine:
vim-cmd vmsvc/power.on "${MYVM}"

echo "The Virtual Machine is now configured and the VM has been started up. The VM is set to use the following configuration:"
echo "Name: ${NAME}"
echo "CPU: ${CPU}"
echo "RAM: ${RAM}"
echo "Guest OS: ${OSVERS}"
echo "Hardware Version: ${HWVERS}"
echo "Hard drive size: ${SIZE}"
if [ -n "${ISO}" ]; then
	echo "ISO: ${ISO}"
else
	echo "No ISO added."
fi
if [ "$VNCSTATUS" = "TRUE" ]; then
	echo "VNC Port: ${VNCPORT}"
	echo "VNC Password: ${VNCPASS}"
else
	echo "VNC not enabled."
fi
exit