# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

# variables.tf
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "gcp_project_id" {
  type = string
}

variable "cloud_weights" {
  type = object({
    aws   = number
    azure = number
  })
  default = {
    aws   = 80
    azure = 20
  }

  validation {
    condition     = (var.cloud_weights.aws + var.cloud_weights.azure) == 100
    error_message = "Total weights must sum to 100."
  }
}

# main.tf
locals {
  common_tags = {
    Project     = "Global-HA"
    Provisioner = "Terraform-Mastery"
  }
}

# GCP Global Traffic Control
resource "google_compute_global_forwarding_rule" "global_lb" {
  name       = "global-lb"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

# AWS Infrastructure
resource "aws_elb" "primary" {
  name               = "primary-lb"
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

# Azure Infrastructure
resource "azurerm_public_ip" "dr_ip" {
  name                = "dr-ip"
  location            = "West Europe"
  resource_group_name = "my-rg"
  allocation_method   = "Static"
}

# Logic Layer: Weighted DNS Record
# (Demonstrating how GCP refers to AWS and Azure attributes)
resource "google_dns_record_set" "app" {
  name         = "app.example.com."
  managed_zone = "example-zone"
  type         = "A"
  ttl          = 60

  routing_policy {
    wrr {
      weight  = var.cloud_weights.aws / 100
      rrdatas = [aws_elb.primary.dns_name] # In reality, you'd resolve DNS to IP or use CNAME
    }
    wrr {
      weight  = var.cloud_weights.azure / 100
      rrdatas = [azurerm_public_ip.dr_ip.ip_address]
    }
  }
}
