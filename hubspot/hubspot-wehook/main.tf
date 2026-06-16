terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}


resource "google_storage_bucket" "function_bucket" {
  name                        = "${var.project_id}-hubspot-webhook-src"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function.zip"
}

resource "google_storage_bucket_object" "function_source" {
  name   = "function-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_source.output_path
}

resource "google_cloudfunctions2_function" "hubspot_webhook" {
  name     = "hubspot-webhook"
  location = var.region

  build_config {
    runtime     = "go121"
    entry_point = "HubSpotWebhook"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    min_instance_count = 0
    max_instance_count = 10
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = var.region
  service  = google_cloudfunctions2_function.hubspot_webhook.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "webhook_url" {
  value = google_cloudfunctions2_function.hubspot_webhook.service_config[0].uri
}
