provider "proxmox" {
  pm_user         = var.credentials.proxmox.user
  pm_password     = var.credentials.proxmox.password
  pm_api_url      = "https://${var.credentials.proxmox.ip}:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
  pm_debug        = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}
