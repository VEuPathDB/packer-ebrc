variable "cpus" {
  type    = number
  default = null
}

variable "memory" {
  default = 2048
}

variable "headless" {
  default = true
}

source "qemu" "rocky-9-64-puppet" {
  iso_url           = "builds/libvirt/rocky-9-64-base/rocky-9-64-base"
  disk_image        = true
  iso_checksum      = "none"
  output_directory  = "builds/libvirt/rocky-9-64-puppet"
  shutdown_command  = "/usr/bin/systemctl poweroff"
  disk_interface    = "virtio"
  cpus              = var.cpus
  memory            = var.memory
  headless          = var.headless
  format            = "qcow2"
  accelerator       = "kvm"
  ssh_username      = "root"
  ssh_password      = "ebrc"
  ssh_timeout       = "5m"
  vm_name           = "rocky-9-64-puppet"
  net_device        = "virtio-net"
  boot_wait         = "5s"
  qemuargs          = [
    [
      "-cpu","host"
    ]
  ]
}

build {
  name = "ebrc"
  sources = ["source.qemu.rocky-9-64-puppet"]

  provisioner "shell" {
    scripts = [
      "scripts/puppet.sh",
      "scripts/cleanup.sh",
      "scripts/zerodisk.sh"
    ]
  }
}
