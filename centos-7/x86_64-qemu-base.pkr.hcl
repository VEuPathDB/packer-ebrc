source "qemu" "centos-7-64-base" {
  iso_url           = "https://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-Minimal-1910-01.iso"
  iso_checksum      = "sha256:a3003276816cf0d8792588c1b5b69c9076cac2f842753c3007fa1bedfaec2d2c"
  output_directory  = "builds/libvirt/centos-7-64-base"
  shutdown_command  = "/sbin/halt -h -p"
  disk_size         = 40520
  memory            = 512
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "ebrc"
  ssh_timeout       = "60m"
  vm_name           = "centos-7-64-base"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
}

build {
  name = "ebrc"
  sources = ["source.qemu.centos-7-64-base"]

  provisioner "shell" {
    scripts = [
      "scripts/yumupdate.sh",
      "scripts/remove_extra_kernels.sh",
      "scripts/cleanup.sh",
      "scripts/zerodisk.sh"
    ]
  }

}

