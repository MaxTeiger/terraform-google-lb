# Google Load Balancer Terraform module

Terraform module which creates **Load Balancer** resources on **GCP**. 
<!-- This module is an abstraction of the [MODULE_NAME](https://github.com/a_great_module) by [@someoneverysmart](https://github.com/someoneverysmart). -->

## User Stories for this module

- AASRE I can create one load balancer
- AASRE I can specify multiple backend services
- AASRE I can specify certificates to be used
- AASRE I can handle granular routing on LB
- AASRE I can specify the SSL Policy
- AASRE I can specify the security policy
- AASRE I can activate CDN on each backend service

## Usage

```hcl
module "my_lb" {
  source = "git@github.com:padok-team/terraform-google-lb.git?ref=v1.0.1"

  name = "my-lb"
  buckets_backends = {
    frontend = {
      hosts = ["example-bucket.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      bucket_name = "example-bucket"
      cdn_policy  = "react"
    }
  }
  service_backends = {
    backend = {
      hosts = ["echo.playground.padok.cloud"]
      path_rules = [
        {
          paths = ["/*"]
        }
      ]
      groups = [google_compute_region_network_endpoint_group.backend.id]
    }
  }
  ssl_certificates    = [data.google_compute_ssl_certificate.playground.self_link]
  custom_cdn_policies = {}
}
```

### Embedded CDN Policies

Currently, this module only supports the following CDN policy. You can reference it directly in the module usage:

- **react**

```hcl
react = {
  cache_mode       = "USE_ORIGIN_HEADERS"
  negative_caching = true
  negative_caching_policy = {
    "404" = {
      code = "404"
      ttl  = "1"
    },
  }
}
```

Don't hesitate to add other CDN policies!

Alternatively, you can set custom CDN Policies as explained in the [Terraform documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket#cdn_policy).

> :warning: The structure of the resource might change, we're based on google provider 3.90 version.

## Usage examples

- [Multiple backend usage](examples/multi-backend-lb/main.tf)
- [Custom CDN policy usage](examples/custom-cdn-policy/main.tf)
- [Custom certificate usage](examples/lb-with-custom-certificate/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buckets_backends"></a> [buckets\_backends](#input\_buckets\_backends) | A map of buckets to add as the load balancer backends. | <pre>map(object({<br>    hosts       = list(string)<br>    bucket_name = string<br>    cdn_policy  = optional(string)<br>    path_rules = list(object({<br>      paths = list(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The load balancer name. | `string` | n/a | yes |
| <a name="input_service_backends"></a> [service\_backends](#input\_service\_backends) | A map of services to add as the load balancer backends. | <pre>map(object({<br>    hosts  = list(string)<br>    groups = list(string)<br>    path_rules = list(object({<br>      paths = list(string)<br>    }))<br>    security_policy = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_custom_cdn_policies"></a> [custom\_cdn\_policies](#input\_custom\_cdn\_policies) | A map of additional custom CDN policies you can add to the load balancer. | <pre>map(object({<br>    cache_mode       = optional(string)<br>    client_ttl       = optional(number)<br>    default_ttl      = optional(number)<br>    max_ttl          = optional(number)<br>    negative_caching = optional(bool)<br>    negative_caching_policy = optional(map(object({<br>      code = optional(number)<br>      ttl  = optional(number)<br>    })))<br>    serve_while_stale            = optional(number)<br>    signed_url_cache_max_age_sec = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | The load balancer's IP address. | `string` | `""` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | A list of SSL certificates for the load balancer. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The IP address of the load balancer. |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
