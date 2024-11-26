variable "iso_url" {
  default = "https://dl.rockylinux.org/pub/rocky/9.5/isos/x86_64/Rocky-9.5-x86_64-boot.iso"
}

variable "iso_sha256" {
  default = "628c069c9685477360640a6b58dc919692a11c44b49a50a024b5627ce3c27d5f"
}

variable "disk_size" {
  default = 40960
}

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

source "qemu" "rocky-9-64-base" {
  iso_url           = var.iso_url
  iso_checksum      = "sha256:${var.iso_sha256}"
  output_directory  = "builds/libvirt/rocky-9-64-base"
  shutdown_command  = "/usr/bin/systemctl poweroff"
  disk_interface    = "virtio"
  cpus              = var.cpus
  disk_size         = var.disk_size
  memory            = var.memory
  headless          = var.headless
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "ebrc"
  ssh_timeout       = "60m"
  vm_name           = "rocky-9-64-base"
  net_device        = "virtio-net"
  boot_wait         = "5s"
  boot_command      = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
  qemuargs          = [
    [
      "-cpu", "host"
    ]
  ]
}

build {
  name = "ebrc"
  sources = ["source.qemu.rocky-9-64-base"]

  provisioner "shell" {
    scripts = [
      "scripts/yumupdate.sh",
      "scripts/cleanup.sh",
      "scripts/zerodisk.sh"
    ]
  }
}
