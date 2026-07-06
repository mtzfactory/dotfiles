# main.tf — Estructura de directorios del home lab en el M8
#
# Terraform (provider local) declara el árbol ~/home-lab de forma
# reproducible. Cada servicio co-localiza su docker-compose.yml y sus datos.

terraform {
  required_version = ">= 1.5"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

locals {
  service_dirs = [
    for svc in var.services : "${var.home_lab_root}/services/${svc}"
  ]
  data_dirs = [
    for svc in var.services : "${var.home_lab_root}/services/${svc}/data"
  ]
  base_dirs = [
    var.home_lab_root,
    "${var.home_lab_root}/services",
    "${var.home_lab_root}/scripts",
    "${var.home_lab_root}/obsidian",
  ]
  all_dirs = concat(local.base_dirs, local.service_dirs, local.data_dirs)
}

# El provider local no crea directorios per se; se usa un fichero .keep
# por directorio como recurso declarativo.
resource "local_file" "keep" {
  for_each = toset(local.all_dirs)

  filename = "${each.value}/.keep"
  content  = "managed by terraform\n"
}
