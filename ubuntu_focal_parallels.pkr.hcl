packer {
  required_plugins {
    parallels = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/parallels"
    }
  }
}

variable "ubuntu_focal_iso_url" {
  type = string
    default = "https://mirror.yandex.ru/ubuntu-releases/20.04.2.0/ubuntu-20.04.2-live-server-amd64.iso"
  // default = "file:///Users/username/Downloads/ubuntu-20.04.2-live-server-amd64.iso"
}

variable "iso_target_dir" {
  type    = string
  default = "~/Downloads"
}

variable "ssh_local_user" {
  type = string
  default = "ubuntu"
}

variable "ssh_local_pass" {
  type = string
  default = "ubuntu"
}

source "parallels-iso" "ubuntu_focal" {
  // ISO
  guest_os_type   = "ubuntu"
  iso_url         = "${var.ubuntu_focal_iso_url}"
  iso_checksum    = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
  iso_target_path = "${var.iso_target_dir}"
  // Parallels
  parallels_tools_flavor = "lin"
  parallels_tools_mode   = "attach"
  // Guest
  ssh_username = "${var.ssh_local_user}"
  ssh_password = "${var.ssh_local_pass}"
  ssh_timeout  = "20m"
  // VM
  cpus      = "4"
  disk_size = "20480"
  memory    = "4096"
  // Boot
  http_directory = "${path.root}/http"
  boot_wait      = "2s"
  boot_command = [
    "<enter><wait2><enter><wait><f6><esc><wait>",
    "autoinstall <wait2> ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  // Shutdown
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.parallels-iso.ubuntu_focal"]

  provisioner "shell" {
    environment_vars = [
      "PACKER_SOURCE=${var.ubuntu_focal_iso_url}",
    ]
    inline = [
      "echo \"Installed from $PACKER_SOURCE\" > build_source.txt",
    ]
  }

  provisioner "file" {
  source = "postinstall.yaml"
  destination = "/tmp/postinstall.yaml"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "echo Setup parallels_tools from cdrom...",
      "sudo mount /dev/sr1 /mnt",
      "cd /mnt && sudo ./install --install-unattended-with-deps --progress",
      "cd / && sudo umount /mnt",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get install ansible -y",
      "ansible-playbook -b --connection=local --inventory '127.0.0.1 ansible_ssh_user=${var.ssh_local_user} ansible_ssh_pass=${var.ssh_local_pass}', /tmp/postinstall.yaml",
    ]
  }

}
     