locals {
  ports_config = jsondecode(file("./ports.json"))
  ports = [for config in local.ports_config: config.Port]
  name = [for config in local.ports_config: config.Name]
}