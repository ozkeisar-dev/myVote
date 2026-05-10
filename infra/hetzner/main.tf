data "hcloud_ssh_key" "main" {
  name = var.ssh_key_name
}

locals {
  common_labels = {
    project    = "myvote"
    managed_by = "terraform"
  }
}

resource "hcloud_server" "coolify_host" {
  name        = "myvote-coolify"
  server_type = var.server_types.coolify_host
  image       = var.image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.main.id]
  labels      = merge(local.common_labels, { role = "coolify-host" })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "app_staging" {
  name        = "myvote-app-staging"
  server_type = var.server_types.app_staging
  image       = var.image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.main.id]
  labels      = merge(local.common_labels, { role = "app", env = "staging" })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "app_prod" {
  name        = "myvote-app-prod"
  server_type = var.server_types.app_prod
  image       = var.image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.main.id]
  labels      = merge(local.common_labels, { role = "app", env = "prod" })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
