
variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "node_type" {
default = "n1-standard-1"
description = "node type you want to use "

}

resource "random_id" "username" {
  byte_length = 14
}

resource "random_id" "password" {
  byte_length = 16
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    username = random_id.username.hex
    password = random_id.password.hex

    client_certificate_config {
      issue_client_certificate = true
    }
  }
  addons_config {
    http_load_balancing {
      disabled = false
    }

  horizontal_pod_autoscaling {
    disabled = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "kuberenetes-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_locations = [
   "europe-north1-a"
  ]

  node_config {
    oauth_scopes = []

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.node_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig-template.yaml")

  vars = {
    cluster_name    = google_container_cluster.primary.name
    user_name       = google_container_cluster.primary.master_auth[0].username
    user_password   = google_container_cluster.primary.master_auth[0].password
    endpoint        = google_container_cluster.primary.endpoint
    cluster_ca      = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
    client_cert     = google_container_cluster.primary.master_auth[0].client_certificate
    client_cert_key = google_container_cluster.primary.master_auth[0].client_key
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${path.module}/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig"
  }
}

resource "helm_release" "local" {
  depends_on = [
    local_file.kubeconfig,google_container_node_pool.primary_nodes
  ]
  name       = "jenkins-k8s"
  chart      = "./jenkins"
}

output "node_version" {
  value = google_container_cluster.primary.node_version
}

output "kubeconfig_path" {
  value = local_file.kubeconfig.filename
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}