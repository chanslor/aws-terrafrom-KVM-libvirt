terraform {
  required_version = ">= 0.13"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

#variable "hostnames" {
#  description = "List of hostnames to create"
#  type        = list(string)
#}
#
#variable "memory" {
#  description = "Memory size for each VM (in MB)"
#  type        = number
#  default     = 1024
#}
#
#variable "vcpus" {
#  description = "Number of vCPUs for each VM"
#  type        = number
#  default     = 2
#}
#
#variable "disk_size" {
#  description = "Disk size for each VM (in GB)"
#  type        = number
#  default     = 20
#}

resource "libvirt_volume" "vm_disk" {
  count  = length(var.hostnames)
  name   = "${var.hostnames[count.index]}-disk"
  pool   = "default"
  source = "/var/lib/libvirt/images/amazon/al2023-kvm-2023.5.20240916.0-kernel-6.1-x86_64.xfs.gpt.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  network_config = file("${path.module}/network_config.cfg")
  user_data      = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_domain" "vm" {
  count  = length(var.hostnames)
  name   = var.hostnames[count.index]
  memory = var.memory
  vcpu   = var.vcpus

  cpu {
    mode = "host-passthrough"
  }

  firmware = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  nvram {
    file = "/var/lib/libvirt/qemu/nvram/${var.hostnames[count.index]}_VARS.fd"
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
    scsi      = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "none"
  }

  # Remote execution to set hostname on each VM
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.hostnames[count.index]}",
      "sudo yum -y install ansible",
      "sudo shutdown -r +1"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user" # Change as needed
      private_key = file("/home/mdc/.ssh/id_rsa")
      host        = self.network_interface.0.addresses[0]
    }
  }
}

output "vm_ips" {
  value = { for i, vm in libvirt_domain.vm : var.hostnames[i] => vm.network_interface.0.addresses[0] }
}

output "ALL_HOSTS" {
  value       = join(" ", [for vm in libvirt_domain.vm : vm.network_interface.0.addresses[0]])
  description = "Space-separated list of all VM IPs for terminal usage"
}

