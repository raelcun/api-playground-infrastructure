variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Default Google Cloud region"
}

terraform {
  backend "gcs" {
    bucket      = "api-playground-terraform-state"
    prefix      = "terraform"
    credentials = "account.json"
  }
}

provider "google-beta" {
  credentials = file("account.json")
  project     = var.project
  region      = var.region
}

