locals {
  embedded_cdn_policies = {
    react = {
      cache_mode       = "USE_ORIGIN_HEADERS"
      negative_caching = true
      negative_caching_policy = {
        code = "404"
        ttl  = "1"
      }
    },
  }
  cdn_policies = merge(local.embedded_cdn_policies, var.custom_cdn_policies)
}
