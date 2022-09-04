resource "volterra_origin_pool" "unit_origins" {
  for_each = var.origins
  name                   = "${each.key}"
  namespace              = volterra_namespace.ns.name
  description            = format("Origin server")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("${var.servicename}.%s", volterra_namespace.ns.name)
      site_locator {
        virtual_site {
          name      = volterra_virtual_site.main.name
          namespace = volterra_namespace.ns.name
        }
      }
    }
  }
  port               = "${each.value}"
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}
