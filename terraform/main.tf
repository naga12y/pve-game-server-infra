# 変数ファイルから取得する
variable "cores" {
  type    = number
  default = 2
}
variable "sockets" {
  type    = number
  default = 2
}
variable "memory" {
  type    = number
  default = 4096
}
variable "disk_size" {
  type    = number
  default = 50
}
variable "ip_address" {
  type    = string
  default = ""
}
variable "ip_gateway" {
  type    = string
  default = ""
}
variable "username" {
  type    = string
  default = "root"
}
variable "cipassword" {
  type    = string
  default = ""
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
}

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.sshkey.private_key_pem
  filename = "terraform_rsa"
  file_permission = "0400"
}

output "private_key_pem" {
  value     = tls_private_key.sshkey.private_key_pem
  sensitive = true
}

resource "proxmox_vm_qemu" "pve-test-vm1" {
  name = "pve.test.vm1"
  target_node = "pve02"
  onboot = true
  #iso = "local:iso/ubuntu-24.04.2-desktop-amd64.iso"
  vmid = 210
  clone = "vm-debian-template"
  os_type = "cloud-init"
  cores   = "${var.cores}"
  memory  = "${var.memory}"
  serial {
    id = 0
    type = "socket"
  }
  disk {
    slot = "ide0"
    storage = "local-lvm"
    type = "cloudinit"
  }
  disk {
    slot = "scsi0"
    storage = "local-lvm"
    size = "${var.disk_size}G"
  }
  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
  }
  ipconfig0 = "ip=${var.ip_address}/24,gw=${var.ip_gateway}"
  ciuser = "${var.username}"
  cipassword = "${var.cipassword}"
#   sshkeys = <<EOF
#   ${file("./ipa.pub")}
# EOF
  sshkeys = tls_private_key.sshkey.public_key_openssh
  boot = "order=scsi0"

  connection {
    host = "${var.ip_address}" # IP address of the host where commands will run
    user = "${var.username}" # User
    //private_key = file("./ipa") # Path to private SSH key located on host running Terraform.
    private_key = local_file.private_key.content # Path to private SSH key located on host running Terraform.
    agent = false # Disable ssh-agent authentication
    timeout = "3m" # This is the timeout for the connection to be established
  }

  # Deliver target file to remote host
  provisioner "file" {
    source   = "../util-scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo sh /tmp/setup.sh",
    ]
  }
}