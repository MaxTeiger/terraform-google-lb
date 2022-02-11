resource "google_compute_global_address" "this" {
  count      = var.ip_address == "" ? 1 : 0
  name       = var.name
  ip_version = "IPV4"
}

resource "google_compute_url_map" "https" {
  name = "${var.name}-https"

  default_service = try(google_compute_backend_bucket.this[keys(google_compute_backend_bucket.this)[0]].self_link, google_compute_backend_service.this[keys(google_compute_backend_service.this)[0]].self_link)

  dynamic "host_rule" {
    for_each = var.service_backends

    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.key
    }
  }

  dynamic "host_rule" {
    for_each = var.buckets_backends

    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.key
    }
  }

  dynamic "path_matcher" {
    for_each = var.service_backends
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_service.this[path_matcher.key].self_link
      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules

        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.this[path_matcher.key].self_link
        }
      }
    }
  }

  dynamic "path_matcher" {
    for_each = var.buckets_backends
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_bucket.this[path_matcher.key].self_link
      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules

        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_bucket.this[path_matcher.key].self_link
        }
      }
    }
  }
}

resource "google_compute_url_map" "http" {
  name = "${var.name}-http"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}

resource "google_compute_ssl_policy" "this" {
  name            = var.name
  min_tls_version = "TLS_1_2"
  profile         = "RESTRICTED"
}

resource "google_compute_target_https_proxy" "this" {
  name             = "${var.name}-https"
  url_map          = google_compute_url_map.https.self_link
  ssl_certificates = var.ssl_certificates
  ssl_policy       = google_compute_ssl_policy.this.self_link
}

resource "google_compute_target_http_proxy" "this" {
  name    = "${var.name}-http"
  url_map = google_compute_url_map.http.self_link
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.name}-https"
  target     = google_compute_target_https_proxy.this.self_link
  ip_address = local.ip_address
  port_range = 443
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.name}-http"
  target     = google_compute_target_http_proxy.this.self_link
  ip_address = local.ip_address
  port_range = 80
}


# -----------------------------
# BACKEND SERVICES
# -----------------------------
# SERVICE

# create a random_id to suffix `google_compute_backend_service.this`
# > required to enable `lifecycle.create_before_destroy`
resource "random_id" "backend_service" {
  for_each = var.service_backends

  byte_length = 4
  prefix      = "${var.name}-${each.key}-"

  keepers = {
    security_policy = each.value.security_policy
    groups          = join(",", each.value["groups"])
  }
}

resource "google_compute_backend_service" "this" {
  for_each = var.service_backends

  name            = random_id.backend_service[each.key].hex
  security_policy = each.value.security_policy
  enable_cdn      = false

  dynamic "backend" {
    for_each = toset(each.value["groups"])
    content {
      group = backend.value
    }
  }

  lifecycle {
    # Need because url_map updating after terraform try to delete the resource
    create_before_destroy = true
  }
}

# BUCKET

# create a random_id to suffix `google_compute_backend_bucket.this`
# > required to enable `lifecycle.create_before_destroy`
resource "random_id" "backend_bucket" {
  for_each = var.buckets_backends

  byte_length = 4
  prefix      = "${var.name}-${each.key}-"

  keepers = {
    bucket_name  = each.value.bucket_name
    cdn_policies = each.value.cdn_policy == null ? jsonencode(local.cdn_policies) : ""
  }
}

resource "google_compute_backend_bucket" "this" {
  for_each = var.buckets_backends

  name        = random_id.backend_bucket[each.key].hex
  bucket_name = each.value.bucket_name
  enable_cdn  = each.value.cdn_policy == null ? false : true

  dynamic "cdn_policy" {
    for_each = (each.value.cdn_policy == null ? false : true) ? { default = each.value.cdn_policy } : {}
    content {
      cache_mode                   = try(local.cdn_policies[cdn_policy.value].cache_mode, null)
      client_ttl                   = try(local.cdn_policies[cdn_policy.value].client_ttl, null)
      default_ttl                  = try(local.cdn_policies[cdn_policy.value].default_ttl, null)
      max_ttl                      = try(local.cdn_policies[cdn_policy.value].max_ttl, null)
      negative_caching             = try(local.cdn_policies[cdn_policy.value].negative_caching, null)
      serve_while_stale            = try(local.cdn_policies[cdn_policy.value].serve_while_stale, null)
      signed_url_cache_max_age_sec = try(local.cdn_policies[cdn_policy.value].signed_url_cache_max_age_sec, null)

      dynamic "negative_caching_policy" {
        for_each = local.cdn_policies[cdn_policy.value].negative_caching_policy
        content {
          code = try(negative_caching_policy.value.code, null)
          ttl  = try(negative_caching_policy.value.ttl, null)
        }
      }
    }
  }

  lifecycle {
    # Need because url_map updating after terraform try to delete the resource
    create_before_destroy = true
  }
}
