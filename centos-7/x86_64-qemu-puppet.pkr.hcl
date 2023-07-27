source "qemu" "centos-7-64-puppet" {
  iso_url           = "builds/libvirt/centos-7-64-puppet/centos-7-64-puppet"
  iso_checksum      = "none"
  output_directory  = "builds/libvirt/centos-7-64-puppet"
  shutdown_command  = "/sbin/halt -h -p"
  disk_image        = true
  disk_size         = 40520
  memory            = 512
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "ebrc"
  ssh_timeout       = "5m"
  vm_name           = "centos-7-64-puppet"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
}

build {
  name = "ebrc"
  sources = ["source.qemu.centos-7-64-puppet"]

  provisioner "shell" {
    scripts = [
      "scripts/bootstrap-puppet.sh",
      "scripts/cleanup.sh",
      "scripts/zerodisk.sh"
    ]
  }

}
