# Volterra Example - voltstack Customer Edge Site

This is a teraform example of customer edge site on Volterra. This specific example builds a customer edge site in AWS.

This is based on the documentation available at [Volterra.io](http://volterra.io)

## Explanation

As part of learning the Volterra platform, I have created a few scenario's that shows different functionality. 
This scenario is a customer edge site and a single application. The customer edge site runs in AWS.

This will become clearer over the course of the README.


## Architecture

The architecture is relatively simple. I have a single application that is an API that has multiple enpoints.
This application is distributed to a number of volterra edge sites. In the Volterra lexicon these are called Regional Edge sites or RE.

Volterra edge sites are sites that are fully managed by Volterra. This makes them a good place to start, and to get up and running quickly.

### Applications

I have a single application that is an API - the starwars API.
It has the following endpoints

/people
/starships
/vehicles
/species
/films

Each endpoint has a number of records (and some refer to each other).

At the / endpoint there is a simple website.


### Load Generator

I have created a load generator application. This application does the following things:

1. Uses the tor network in order to present different source IP addresses
2. Runs a basic shell script to push some traffic through the API endpoints.

### Namespace

There is a single namespace in the example application. This is created by the terraform scripts.

This is configured by the terraform variable **ns**. 

```
variable "ns" { default = "s-vk" }
```

In my example, I'm using my initials as the namespace 

### Sites

Volterra has the concept of sites. Within the example, there is a single site. 
The site is configured using a concatenation of the terraform variable namespace name, and adding the suffix **vs** to denote a virtual site.

```
name      = format("%s-vs", volterra_namespace.ns.name)
```

The net effect is that the namespace name has **vs** added to it, so in this example, it will be **s-vk-vs**.

The resource that I use in terraform to create the virtual site is below:

```
resource "volterra_virtual_site" "main" {
  name      = format("%s-vs", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [time_sleep.ns_wait]

  labels = {
    "ves.io/siteName" = "ves-io-sg3-sin"
  }
  site_selector {
    expressions = var.site_selector
  }
  site_type = "REGIONAL_EDGE"
}
```

The three important pieces here are:

- labels
- site selector
- site type

**Labels**

**Site Selector**

**Site Type**



### Virtual Kubernetes

There is also a virtual kubernetes site, vk8s for short. This is associated with the site, this is explained later and is primarily for deployment purposes.

Virtual kubernetes is a kubernetes like API that allows me to run a virtual kubernetes deployment within the Volterra RE (Regional Edge) site. The virtual kubernetes site and API allows me to deploy pods and create services. This allows me to use standard kubernetes devices, such as manifests, and so on to deploy my applications.

```
resource "volterra_virtual_k8s" "vk8s" {
  name      = format("%s-vk8s", volterra_namespace.ns.name)
  namespace = volterra_namespace.ns.name
  depends_on = [volterra_virtual_site.main]

  vsite_refs {
    name      = volterra_virtual_site.main.name
    namespace = volterra_namespace.ns.name
  }
}
```



### API Discovery

