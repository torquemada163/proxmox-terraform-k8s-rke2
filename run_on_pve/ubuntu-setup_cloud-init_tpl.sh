#!/bin/bash

SRC_IMG="http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
IMG_NAME="focal-server-cloudimg-amd64.qcow2"

wget -O $IMG_NAME $SRC_IMG

TEMPL_NAME="ubuntu-cloudinit"
VMID="9001"
MEM="1024"
DISK_STOR="wd-lvm"
NET_BRIDGE="vmbr0"
SSH_KEY="/root/user.pub"

apt update
apt install -y libguestfs-tools
virt-customize --install qemu-guest-agent -a $IMG_NAME

qm create $VMID -name $TEMPL_NAME -memory $MEM -net0 virtio,bridge=$NET_BRIDGE -cores 1 -sockets 1
qm importdisk $VMID $IMG_NAME $DISK_STOR
qm set $VMID -scsihw virtio-scsi-pci -virtio0 $DISK_STOR:vm-$VMID-disk-0
qm set $VMID -serial0 socket
qm set $VMID -boot c -bootdisk virtio0
qm set $VMID -agent 1
qm set $VMID -hotplug disk,network,usb
qm set $VMID -vcpus 1
qm set $VMID -vga qxl
qm set $VMID -ide2 $DISK_STOR:cloudinit
qm set $VMID -vmgenid 1
qm set $VMID -ciuser ciuser
qm set $VMID -sshkey $SSH_KEY
qm set $VMID --ipconfig0 ip=dhcp

qm template $VMID
