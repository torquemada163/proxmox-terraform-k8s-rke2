resource "proxmox_vm_qemu" "vm_node" {
  count = 3
  name  = "node-${count.index}"

  target_node = "pve"

  clone      = var.vmdata.os_template
  os_type    = "cloud-init"

  agent                   = var.vmdata.normal_machine_id ? 1 : 0
  define_connection_info  = true
  ipconfig0               = var.vmdata.normal_machine_id ? "ip=dhcp" : "ip=${var.vmdata.ip_first_three_block}.${var.vmdata.ip_last_block_start + count.index}/24,gw=${var.vmdata.ip_gw}"
  nameserver              = var.vmdata.normal_machine_id ? "" : var.vmdata.ip_dns

  cores    = 1
  sockets  = 1
  memory   = 2048
  hotplug  = "disk,usb,network"
  scsihw   = "virtio-scsi-pci"
  bootdisk = "virtio0"


  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  disk {
    size        = "20G"
    type        = "virtio"
    storage     = var.vmdata.diskstorage
  }
}

resource "local_file" "inventory" {
  count = var.vmdata.normal_machine_id ? 1 : 0
  filename = "inventory"
  content  = <<-EOT
[vm_node]
%{ for instance in proxmox_vm_qemu.vm_node ~}
${instance.name} ansible_host=${instance.ssh_host}
%{ endfor ~}
  EOT
}