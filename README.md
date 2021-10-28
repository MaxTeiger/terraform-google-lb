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

- [Example of use case](examples/example_of_use_case/main.tf)
- [Example of other use case](examples/example_of_other_use_case/main.tf)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
