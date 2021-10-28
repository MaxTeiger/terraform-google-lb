# GCP Load Balancer Terraform module

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
module "example" {
  source = "https://github.com/padok-team/terraform-aws-example"

  example_of_required_variable = "hello_world"
}
```

## Examples

- [Example of use case](examples/simple_use_case/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buckets_backends"></a> [buckets\_backends](#input\_buckets\_backends) | Map of buckets to add as Load Balancer backends | <pre>map(object({<br>    hosts       = list(string)<br>    bucket_name = string<br>    cdn_policy  = optional(string)<br>    path_rules = list(object({<br>      paths = list(string)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Load Balancer name | `string` | n/a | yes |
| <a name="input_service_backends"></a> [service\_backends](#input\_service\_backends) | Map of services to add as Load Balancer backends. | <pre>map(object({<br>    hosts  = list(string)<br>    groups = list(string)<br>    path_rules = list(object({<br>      paths = list(string)<br>    }))<br>    security_policy = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_custom_cdn_policies"></a> [custom\_cdn\_policies](#input\_custom\_cdn\_policies) | Custom CDN Policies you can add to default policies supported by module | <pre>map(object({<br>    cache_mode       = optional(string)<br>    client_ttl       = optional(number)<br>    default_ttl      = optional(number)<br>    max_ttl          = optional(number)<br>    negative_caching = optional(number)<br>    negative_caching_policy = optional(object({<br>      code = optional(number)<br>      ttl  = optional(number)<br>    }))<br>    serve_while_stale            = optional(bool)<br>    signed_url_cache_max_age_sec = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | SSL certificates for the Load Balancer | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example"></a> [example](#output\_example) | A meaningful description |
<!-- END_TF_DOCS -->
