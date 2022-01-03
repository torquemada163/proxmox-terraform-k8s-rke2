resource "proxmox_vm_qemu" "vm_master" {
  count = var.vmdata.master_count
  name  = "master-${count.index}"

  target_node = "pve"

  clone      = var.vmdata.os_template
  os_type    = "cloud-init"

  agent                   = 1
  define_connection_info  = true
  ipconfig0               = var.vmdata.ip_dhcp ? "ip=dhcp" : "ip=${var.vmdata.ip_first_three_block}.${var.vmdata.ip_last_block_start + count.index}/24,gw=${var.vmdata.ip_gw}"
  nameserver              = var.vmdata.ip_dhcp ? "" : var.vmdata.ip_dns

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

  provisioner "remote-exec" {
    inline = [
      "sudo rm /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo shutdown -r +1"
    ]

    connection {
      type = "ssh"  
      host = self.ssh_host
      user = var.vmdata.ssh_local_user
      private_key = "${file("~/.ssh/id_rsa_linux")}"
      timeout = "2m"
    }
  }
}



resource "proxmox_vm_qemu" "vm_worker" {
  count = var.vmdata.worker_count
  name  = "worker-${count.index}"

  target_node = "pve"

  clone      = var.vmdata.os_template
  os_type    = "cloud-init"

  agent                   = 1
  define_connection_info  = true
  ipconfig0               = var.vmdata.ip_dhcp ? "ip=dhcp" : "ip=${var.vmdata.ip_first_three_block}.${var.vmdata.ip_last_block_start + var.vmdata.master_count + count.index}/24,gw=${var.vmdata.ip_gw}"
  nameserver              = var.vmdata.ip_dhcp ? "" : var.vmdata.ip_dns

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

  provisioner "remote-exec" {
    inline = [
      "sudo rm /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo shutdown -r +1"
    ]

    connection {
      type = "ssh"  
      host = self.ssh_host
      user = var.vmdata.ssh_local_user
      private_key = "${file("~/.ssh/id_rsa_linux")}"
      timeout = "2m"
    }
  }
}



resource "local_file" "inventory" {
  filename = "inventory"
  content  = <<-EOT
[pve_kub_master]
%{ for instance in proxmox_vm_qemu.vm_master ~}
${instance.name} ansible_host=${instance.ssh_host}
%{ endfor ~}

[pve_kub_worker]
%{ for instance in proxmox_vm_qemu.vm_worker ~}
${instance.name} ansible_host=${instance.ssh_host}
%{ endfor ~}
  EOT
}
