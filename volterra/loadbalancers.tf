resource "volterra_tcp_loadbalancer" "unit-config" {
  for_each  = var.tcp_lb
  name      = "${each.key}"
  namespace = var.ns

  listen_port = "${each.value}"
  dns_volterra_managed = true
  domains = ["${var.domain_host}.${var.domain}"]
  advertise_on_public_default_vip = true

  retract_cluster = true

  origin_pools_weights { 
    pool {
      name = "${each.key}"
      namespace = var.ns
    }
  }

  hash_policy_choice_round_robin = true

  depends_on = [ local_file.kubeconfig, volterra_origin_pool.unit_origins ]
}



resource "volterra_http_loadbalancer" "app" {
  name                            = "unit-app-origin"
  namespace                       = volterra_namespace.ns.name
  description                     = "HTTP loadbalancer object for app origin server" 
  domains                         = ["${var.domain_host}.${var.domain}"]
  advertise_on_public_default_vip = true
#  labels                          = { "ves.io/app_type" = volterra_app_type.at.name }
  default_route_pools {
    pool {
      name      = "unit-app1-origin"
      namespace = volterra_namespace.ns.name
    }
  }
#  https_auto_cert {
#    add_hsts      = false
#    http_redirect = true
#    no_mtls       = true
#  }
  http {
    dns_volterra_managed = true
  }
  more_option {
    response_headers_to_add {
        name   = "Access-Control-Allow-Origin"
        value  = "*"
        append = false
    }
  }
  routes {
    simple_route {
      auto_host_rewrite = true
      path {
        prefix = "/config" 
      }
      origin_pools {
        pool {
          name = "unit-config-origin"
        }
      } 
    }
  }
  disable_waf                     = true
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true

  depends_on = [ time_sleep.ns_wait, volterra_tcp_loadbalancer.unit-config ]
}

output "origin" { value = "${var.origins}" }
output "fronend" { value = "${var.domain_host}.${var.domain}" }
