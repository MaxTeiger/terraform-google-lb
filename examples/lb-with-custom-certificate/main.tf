# This example creates a SSL certificate and attach it to e new load balancer

provider "google" {
  project = "padok-playground"
  region  = "europe-west1"
}

resource "google_compute_managed_ssl_certificate" "this" {
  name = "playground-tls"
  managed {
    domains = ["frontend-library.playground.padok.cloud", "www.frontend-library.playground.padok.cloud"]
  }
}

module "my_lb" {
  source = "../.."

  name = "my-lb"
  buckets_backends = {
    frontend = {
      hosts = ["frontend-library.playground.padok.cloud", "www.frontend-library.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = "padok-helm-library"
    }
  }
  service_backends    = {}
  ssl_certificates    = [google_compute_managed_ssl_certificate.this.id]
  custom_cdn_policies = {}
}
