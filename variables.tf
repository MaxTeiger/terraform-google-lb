terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "name" {
  description = "The load balancer name."
  type        = string

  validation {
    condition     = length(var.name) <= 50
    error_message = "The name variable must be shorter than 50 characters."
  }
}

variable "ip_address" {
  description = "The load balancer's IP address."
  type        = string
  default     = ""
  validation {
    condition     = try(regex("^([0-9]{1,3}.){3}[0-9]{1,3}$", var.ip_address), false) || var.ip_address == ""
    error_message = "Please provide a valid IP address."
  }
}

variable "ssl_certificates" {
  description = "A list of SSL certificates for the load balancer."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.ssl_certificates) > 0
    error_message = "The ssl_certificates variable must contain at least 1 certificate."
  }
}

variable "buckets_backends" {
  description = "A map of buckets to add as the load balancer backends."
  type = map(object({
    hosts       = list(string)
    bucket_name = string
    cdn_policy  = optional(string)
    path_rules = list(object({
      paths = list(string)
    }))
  }))
}

variable "service_backends" {
  description = "A map of services to add as the load balancer backends."
  type = map(object({
    hosts  = list(string)
    groups = list(string)
    path_rules = list(object({
      paths = list(string)
    }))
    security_policy = optional(string)
  }))
}

variable "custom_cdn_policies" {
  description = "A map of additional custom CDN policies you can add to the load balancer."
  type = map(object({
    cache_mode       = optional(string)
    client_ttl       = optional(number)
    default_ttl      = optional(number)
    max_ttl          = optional(number)
    negative_caching = optional(bool)
    negative_caching_policy = optional(map(object({
      code = optional(number)
      ttl  = optional(number)
    })))
    serve_while_stale            = optional(number)
    signed_url_cache_max_age_sec = optional(number)
  }))
  default = {}
}
