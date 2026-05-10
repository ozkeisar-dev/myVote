variable "hcloud_token" {
  description = "Hetzner Cloud project-scoped API token. Wired from HCLOUD_TOKEN env in CI."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Hetzner datacenter location."
  type        = string
  default     = "fsn1" # Falkenstein (Germany)
}

variable "image" {
  description = "Server image."
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_key_name" {
  description = "Name of the SSH key already registered in the Hetzner project. Looked up via data source."
  type        = string
}

variable "server_types" {
  description = "Server type per role. cpx* = AMD, cax* = ARM. See https://www.hetzner.com/cloud#pricing"
  type = object({
    coolify_host = string
    app_staging  = string
    app_prod     = string
  })
  default = {
    coolify_host = "cpx21" # 3 vCPU / 4 GB / 80 GB — Coolify orchestrator
    app_staging  = "cpx21" # 3 vCPU / 4 GB / 80 GB
    app_prod     = "cpx31" # 4 vCPU / 8 GB / 160 GB
  }
}
