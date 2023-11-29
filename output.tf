output "userdata" {
  value = data.template_file.dcC-monitoring-k8s-all-cloudinit-userdata.rendered
}