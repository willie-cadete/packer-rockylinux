packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

source "vmware-iso" "rockylinux9-desktop" {
  boot_command           = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/Rocky-9-Vagrant-VMware-Desktop.ks<enter>"]
  boot_wait              = "10s"
  cores                  = "2"
  memory                 = "4096"
  disk_size              = "100000"
  disk_type_id           = "1"
  disk_adapter_type      = "nvme"
  guest_os_type          = "rockyLinux-64"
  headless               = "false"
  http_directory         = "http"
  iso_checksum           = "sha256:82441c7c9630b313d4183106231b08e192382bb6c7827e62acd467a749f030b9"
  iso_urls               = ["Rocky-9.3-x86_64-dvd.iso","https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-dvd.iso"]
  network                = "nat"
  shutdown_command       = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_handshake_attempts = "10"
  ssh_pty                = true
  ssh_timeout            = "10m"
  ssh_password           = "vagrant"
  ssh_username           = "vagrant"
  ssh_wait_timeout       = "60m"
  vm_name                = "rocky9-desktop"
  version                = "21"
}

build {
  sources = ["source.vmware-iso.rockylinux9-desktop"]

  # provisioner "ansible" {
  #   playbook_file = "./playbooks/playbook.yml"
  # }

  # post-processor "vagrant" {
  #   keep_input_artifact = false
  #   output              = "rhel8-desktop-nocm.box"
  # }

  post-processor "vagrant" {
    output = "output/{{ .Provider }}/{{ .BuildName }}.box"
  }
}
