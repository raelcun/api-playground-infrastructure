variable "machine_type" {
  type        = string
  description = "Machine type to use for the general-purpose node pool. See https://cloud.google.com/compute/docs/machine-types"
}

variable "min_node_count" {
  type        = string
  description = "The minimum number of nodes PER ZONE in the general-purpose node pool"
  default     = 1
}

variable "max_node_count" {
  type        = string
  description = "The maximum number of nodes PER ZONE in the general-purpose node pool"
  default     = 5
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"

}

resource "google_container_cluster" "cluster" {
  provider = google-beta
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "RAPID"
  }

  resource_labels = {
    app = "api-playground"
  }
}

resource "google_container_node_pool" "primary_node_pool" {
  provider           = google-beta
  name               = "primary-node-pool"
  cluster            = google_container_cluster.cluster.name
  location           = var.region
  initial_node_count = var.min_node_count

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Needed for correctly functioning cluster, see 
    # https://www.terraform.io/docs/providers/google/r/container_cluster.html#oauth_scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }
}

