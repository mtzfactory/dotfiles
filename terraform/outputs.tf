output "home_lab_root" {
  value = var.home_lab_root
}

output "service_directories" {
  value = [for svc in var.services : "${var.home_lab_root}/services/${svc}"]
}
