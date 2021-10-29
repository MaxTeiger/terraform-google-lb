locals {
  embedded_cdn_policies = {
    react = {
      cache_mode       = "USE_ORIGIN_HEADERS"
      negative_caching = true
      negative_caching_policy = {
        "404" = {
          code = "404"
          ttl  = "1"
        },
      }
    },
  }
  cdn_policies = merge(local.embedded_cdn_policies, var.custom_cdn_policies)
  ip_address   = var.ip_address == "" ? google_compute_global_address.default[0].address : var.ip_address
}
