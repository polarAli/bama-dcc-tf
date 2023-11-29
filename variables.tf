variable "esxi_hostname" {
  default = "86.104.37.39"
}

variable "esxi_hostport" {
  default = "22"
}

variable "esxi_hostssl" {
  default = "443"
}

variable "esxi_username" {
  default = "root"
}

variable "esxi_password" {
  sensitive = true
}

variable "ubuntu-22-04-server-cloudimg-amd64-ova" {
  default = "/home/polar/Downloads/ubuntu-22.04-server-cloudimg-amd64.ova"
}

variable "dcC-monitoring-WAN-gateway" {
  default = "86.104.37.1"
}

variable "dcC-monitoring-WAN-subnet" {
  default = "24"
}

variable "dcC-monitoring-WAN-nameserver" {
  default = "8.8.8.8"
}

variable "dcC-monitoring-LAN-gateway" {
  default = "172.30.30.1"
}

variable "dcC-monitoring-LAN-subnet" {
  default = "24"
}

variable "dcC-monitoring-LAN-nameserver" {
  default = "8.8.8.8"
}

variable "dcC-monitoring-k8s-lb1-WAN-IP" {
  default = "86.104.37.39"
}

variable "dcC-monitoring-k8s-lb1-LAN-IP" {
  default = "172.30.30.1"
}

variable "dcC-monitoring-k8s-master1-IP" {
  default = "172.30.30.10"
}

variable "dcC-monitoring-k8s-master2-IP" {
  default = "172.30.30.11"
}

variable "dcC-monitoring-k8s-master3-IP" {
  default = "172.30.30.12"
}

variable "dcC-monitoring-k8s-worker1-IP" {
  default = "172.30.30.20"
}

variable "dcC-monitoring-k8s-worker2-IP" {
  default = "172.30.30.21"
}

variable "dcC-monitoring-k8s-worker3-IP" {
  default = "172.30.30.22"
}

variable "dcC-monitoring-k8s-all-userdata-sshPublicKey" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs7qGl6ZZG3zudf7ykR/zQWG/mtkkcUoe6ZbhceIfyf ubuntu@bama-dcC-monitoring-k8s-all"
}

variable "dcC-monitoring-k8s-all-userdata-hashedPassword" {
  default = "$6$rounds=4096$mq/MYqdld.tL8b7B$hkPkQznghPCc1RQGPpItiU1Tj2ojZ/viFbzgrTQYWS8L5fyB7anpej9Rm5iKbzew0Z2In0O2ejMrJyIoAKWMD."
}