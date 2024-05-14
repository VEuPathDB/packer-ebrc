variable "iso_url" {
  default = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.9-x86_64-boot.iso"
}

variable "iso_sha256" {
  default = "88baefca6f0e78b53613773954e0d7c2d8d28ad863f40623db75c40f505b5105"
}

variable "disk_size" {
  default = 40960
}

variable "memory" {
  default = 2048
}

variable "headless" {
  default = true
}

source "qemu" "rocky-8-64-base" {
  iso_url           = var.iso_url
  iso_checksum      = "sha256:${var.iso_sha256}"
  output_directory  = "builds/libvirt/rocky-8-64-base"
  shutdown_command  = "/usr/bin/systemctl poweroff"
  disk_interface    = "virtio"
  disk_size         = var.disk_size
  memory            = var.memory
  headless          = var.headless
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "ebrc"
  ssh_timeout       = "60m"
  vm_name           = "rocky-8-64-base"
  net_device        = "virtio-net"
  boot_wait         = "5s"
  boot_command      = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
}

build {
  name = "ebrc"
  sources = ["source.qemu.rocky-8-64-base"]

  provisioner "shell" {
    scripts = [
      "scripts/yumupdate.sh",
      "scripts/cleanup.sh",
      "scripts/zerodisk.sh"
    ]
  }
}
