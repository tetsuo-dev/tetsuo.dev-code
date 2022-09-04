provider "volterra" {
#  api_p12_file     = "/root/f5-sa.console.ves.volterra.io.api-creds.p12"
#  url              = "https://f5-sa.console.ves.volterra.io/api"
  api_p12_file     = "/root/f5-sales-public.console.ves.volterra.io.api-creds.p12"
  url              = "https://f5-sales-public.console.ves.volterra.io/api"
  timeout          = "120s"
}

resource "volterra_namespace" "ns" {
  name = var.ns
}

resource "time_sleep" "ns_wait" {
  depends_on = [volterra_namespace.ns]
  create_duration = "15s"
}


resource "volterra_aws_vpc_site" "ce" {
  // This replaces all labels, so you should add more than one
  labels = {
    "ce-site-type" = "aws"
  }
  name       = var.site_name
  namespace  = "system"
  aws_region = var.aws_region

  coordinates {
    latitude = "-37.8136"
    longitude = "144.9631"
  }

  aws_cred {
    name      = var.aws_key_name
    namespace = "system"
  }

  vpc {
    new_vpc {
      name_tag = var.aws_vpc_name
      primary_ipv4 = var.aws_vpc_subnet
    }
  }

  instance_type = var.aws_instance_type
  disk_size = "80"

  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true

  // One of the arguments from this list "ingress_gw ingress_egress_gw voltstack_cluster" must be set

  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
    forward_proxy_allow_all = true
    no_global_network = true
//    no_k8s_cluster = true
    k8s_cluster {
      namespace = "system"
      name = volterra_k8s_cluster.example.name
    }
    no_network_policy = true
    no_outside_static_routes = true
    default_storage = true
    az_nodes {
         aws_az_name = format("%sa", var.aws_region)
         local_subnet {
           subnet_param {
             ipv4 = var.aws_az1_subnet
           }
         }
         disk_size = "80"
    } // end of az_nodes
    #az_nodes {
    #     aws_az_name = format("%sb", var.aws_region)
    #     local_subnet {
    #       subnet_param {
    #         ipv4 = var.aws_az2_subnet
    #       }
    #     }
    #     disk_size = "80"
    #} // end of az_nodes
    #az_nodes {
    #     aws_az_name = format("%sc", var.aws_region)
    #     local_subnet {
    #       subnet_param {
    #         ipv4 = var.aws_az3_subnet
    #       }
    #     }
    #     disk_size = "80"
    #} // end of az_nodes
  } //end of voltstack_cluster resource

  // One of the arguments from this list "nodes_per_az total_nodes no_worker_nodes" must be set
  #nodes_per_az = "3"
  no_worker_nodes = true

  depends_on = [ volterra_k8s_cluster.example ]
}

resource "volterra_k8s_cluster" "example" {
  name      = "svk-k8s"
  namespace = "system"

  // One of the arguments from this list "cluster_wide_app_list no_cluster_wide_apps" must be set
  no_cluster_wide_apps = true

  // One of the arguments from this list "use_custom_cluster_role_bindings use_default_cluster_role_bindings" must be set
  use_default_cluster_role_bindings = true

  // One of the arguments from this list "use_default_cluster_roles use_custom_cluster_role_list" must be set
  use_default_cluster_roles = true

  // One of the arguments from this list "no_global_access global_access_enable" must be set
  no_global_access = true

  // One of the arguments from this list "no_insecure_registries insecure_registry_list" must be set
  no_insecure_registries = true

  // One of the arguments from this list "no_local_access local_access_config" must be set

  local_access_config {
    local_domain = "example.com"

    // One of the arguments from this list "default_port port" must be set
    default_port = true
  }
  // One of the arguments from this list "use_default_psp use_custom_psp_list" must be set
  use_default_psp = true
}

resource "volterra_tf_params_action" "ce" {
  site_name       = volterra_aws_vpc_site.ce.name
  site_kind       = "aws_vpc_site"
  action          = "apply"
  wait_for_action = true

  depends_on = [ volterra_aws_vpc_site.ce ]
}

resource "volterra_virtual_site" "main" {
  name      = format("%s-vs", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [volterra_tf_params_action.ce]

  site_selector {
    expressions = [ "ce-site-type in (aws)" ]
  }
  site_type = "CUSTOMER_EDGE"
}

resource "volterra_virtual_k8s" "vk8s" {
  name      = format("%s-vk8s", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [volterra_virtual_site.main]

  vsite_refs {
    name      = volterra_virtual_site.main.name
    namespace = volterra_namespace.ns.name
  }
}

resource "volterra_api_credential" "cred" {
  name      = var.servicename
  api_credential_type = "KUBE_CONFIG"
  virtual_k8s_namespace = volterra_namespace.ns.name
  virtual_k8s_name = volterra_virtual_k8s.vk8s.name
}

resource "time_sleep" "vk8s_cred_wait" {
  create_duration = "30s"
  depends_on = [volterra_api_credential.cred]
}

resource "local_file" "kubeconfig" {
    content = base64decode(volterra_api_credential.cred.data)
    filename = format("%s/%s", path.module, format("%s-vk8s.yaml", terraform.workspace))

    depends_on = [time_sleep.vk8s_cred_wait]
}

