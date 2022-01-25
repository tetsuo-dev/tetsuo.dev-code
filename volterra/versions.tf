terraform {
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
