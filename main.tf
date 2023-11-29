provider "esxi" {
  esxi_hostname      = var.esxi_hostname
  esxi_hostport      = var.esxi_hostport
  esxi_hostssl       = var.esxi_hostssl
  esxi_username      = var.esxi_username
  esxi_password      = var.esxi_password
}

resource "esxi_vswitch" "dcC-monitoring-WAN" {
  name              = "vSwitch0"

  uplink {
    name           = "vmnic0"
  }  
}

resource "esxi_portgroup" "dcC-esxi-management" {
  name              = "Management Network"
}

resource "esxi_portgroup" "dcC-monitoring-WAN" {
  name              = "dcC-monitoring-WAN"
  vlan              = 200
  vswitch           = esxi_vswitch.dcC-monitoring-WAN.name
}

resource "esxi_portgroup" "dcC-monitoring-LAN" {
  name              = "dcC-monitoring-LAN"
  vlan              = 210
  vswitch           = esxi_vswitch.dcC-monitoring-WAN.name
}

resource "esxi_guest" "dcC-monitoring-pfsense1" {
  guest_name         = "dcC-monitoring-pfsense1"
  disk_store         = "datastore1"

  guestos            = "freeBSD-64"

  memsize            = 1024 * 4
  numvcpus           = 4

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  power              = "off"
  # network_interfaces {
  #   virtual_network = esxi_portgroup.dcC-monitoring-WAN.name
  # }

  # network_interfaces {
  #   virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  # }
}

data "template_file" "dcC-monitoring-k8s-all-cloudinit-userdata" {
  template = file("cloudinit-userdata.tpl")
  vars = {
    username = "bama"
    sshPublicKey = var.dcC-monitoring-k8s-all-userdata-sshPublicKey
    hashedPassword = var.dcC-monitoring-k8s-all-userdata-hashedPassword
  }
}

data "template_file" "dcC-monitoring-k8s-lb1-cloudinit-metadata" {
  template = file("cloudinit-metadata-lb.tpl")
  vars = {
    wanIpAddress = var.dcC-monitoring-k8s-lb1-WAN-IP
    wanSubnetMask = var.dcC-monitoring-WAN-subnet
    wanGateway = var.dcC-monitoring-WAN-gateway
    wanNameserver = var.dcC-monitoring-WAN-nameserver
    lanIpAddress = var.dcC-monitoring-k8s-lb1-LAN-IP
    lanSubnetMask = var.dcC-monitoring-LAN-subnet
  }
}

data "template_file" "dcC-monitoring-k8s-master1-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-master1-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

data "template_file" "dcC-monitoring-k8s-master2-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-master2-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

data "template_file" "dcC-monitoring-k8s-master3-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-master3-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-lb1" {
  guest_name         = "dcC-monitoring-k8s-lb1"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 4
  numvcpus           = 4

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-WAN.name
  }

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-lb1-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-lb1"
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-master1" {
  guest_name         = "dcC-monitoring-k8s-master1"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 8
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-master1-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-master1"
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-master2" {
  guest_name         = "dcC-monitoring-k8s-master2"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 8
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-master2-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-master2"
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-master3" {
  guest_name         = "dcC-monitoring-k8s-master3"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 8
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-master3-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-master3"
  }
}

data "template_file" "dcC-monitoring-k8s-worker1-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-worker1-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

data "template_file" "dcC-monitoring-k8s-worker2-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-worker2-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

data "template_file" "dcC-monitoring-k8s-worker3-cloudinit-metadata" {
  template = file("cloudinit-metadata.tpl")
  vars = {
    ipAddress = var.dcC-monitoring-k8s-worker3-IP
    gateway = var.dcC-monitoring-LAN-gateway
    mask = var.dcC-monitoring-LAN-subnet
    nameserver = var.dcC-monitoring-LAN-nameserver
  }
}

resource "esxi_virtual_disk" "dcC-monitoring-k8s-worker1" {
  virtual_disk_disk_store    = "datastore1"
  virtual_disk_dir           = "dcC-monitoring-k8s-topolvms"
  virtual_disk_name          = "dcC-monitoring-k8s-worker1.vmdk"
  virtual_disk_size          = 100
  virtual_disk_type          = "thin"
}

resource "esxi_virtual_disk" "dcC-monitoring-k8s-worker2" {
  virtual_disk_disk_store    = "datastore1"
  virtual_disk_dir           = "dcC-monitoring-k8s-topolvms"
  virtual_disk_name          = "dcC-monitoring-k8s-worker2.vmdk"
  virtual_disk_size          = 100
}

resource "esxi_virtual_disk" "dcC-monitoring-k8s-worker3" {
  virtual_disk_disk_store    = "datastore1"
  virtual_disk_dir           = "dcC-monitoring-k8s-topolvms"
  virtual_disk_name          = "dcC-monitoring-k8s-worker3.vmdk"
  virtual_disk_size          = 100
  virtual_disk_type          = "thin"
}

resource "esxi_guest" "dcC-monitoring-k8s-worker1" {
  guest_name         = "dcC-monitoring-k8s-worker1"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 16
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  virtual_disks {
    virtual_disk_id             = esxi_virtual_disk.dcC-monitoring-k8s-worker1.id
    slot           = "0:1"
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-worker1-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-worker1"
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-worker2" {
  guest_name         = "dcC-monitoring-k8s-worker2"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 16
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  virtual_disks {
    virtual_disk_id             = esxi_virtual_disk.dcC-monitoring-k8s-worker2.id
    slot           = "0:1"
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-worker2-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-worker2"
  }
}

resource "esxi_guest" "dcC-monitoring-k8s-worker3" {
  guest_name         = "dcC-monitoring-k8s-worker3"
  disk_store         = "datastore1"
  

  ovf_source         = var.ubuntu-22-04-server-cloudimg-amd64-ova

  memsize            = 1024 * 16
  numvcpus           = 8

  boot_disk_type     = "thin"
  boot_disk_size     = 50

  network_interfaces {
    virtual_network = esxi_portgroup.dcC-monitoring-LAN.name
  }

  virtual_disks {
    virtual_disk_id             = esxi_virtual_disk.dcC-monitoring-k8s-worker3.id
    slot           = "0:1"
  }

  guestinfo = {
    "metadata.encoding" = "gzip+base64"
    "metadata"          = base64gzip(data.template_file.dcC-monitoring-k8s-worker3-cloudinit-metadata.rendered)
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered)
  }

  ovf_properties {
    key = "hostname"
    value = "dcC-monitoring-k8s-worker3"
  }
}
