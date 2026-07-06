variable "home_lab_root" {
  description = "Raíz del home lab en el servidor"
  type        = string
}

variable "services" {
  description = "Servicios auto-hospedados (un directorio compose por servicio)"
  type        = list(string)
  default = [
    "photoprism",
    "kavita",
    "n8n",
    "ollama",
  ]
}
