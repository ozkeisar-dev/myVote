output "coolify_host" {
  value = {
    name = hcloud_server.coolify_host.name
    ipv4 = hcloud_server.coolify_host.ipv4_address
    ipv6 = hcloud_server.coolify_host.ipv6_address
  }
}

output "app_staging" {
  value = {
    name = hcloud_server.app_staging.name
    ipv4 = hcloud_server.app_staging.ipv4_address
    ipv6 = hcloud_server.app_staging.ipv6_address
  }
}

output "app_prod" {
  value = {
    name = hcloud_server.app_prod.name
    ipv4 = hcloud_server.app_prod.ipv4_address
    ipv6 = hcloud_server.app_prod.ipv6_address
  }
}
