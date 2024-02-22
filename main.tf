terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

module "project-factory_project_services" {
  source              = "terraform-google-modules/project-factory/google//modules/project_services"
  version             = "14.2.0"
  project_id          = var.project_id
  activate_apis       = [ "eventarc.googleapis.com" ]
  disable_services_on_destroy	  = false
}

resource "google_pubsub_topic" "topic" {
  depends_on = [
    module.project-factory_project_services
  ]
  name = var.pubsub_topic
}

resource "google_storage_bucket" "bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source" 
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = var.function_source 
}


resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"

  members = [
    "serviceAccount:cloud-functions-scc-alerts@${var.project_id}.iam.gserviceaccount.com",
  ]
}


resource "google_cloudfunctions2_function" "function" {

  depends_on = [
    google_pubsub_topic.topic,
    google_storage_bucket.bucket
  ]

  name        = var.function_name
  location    = "us-central1"

  build_config {
    runtime     = "nodejs16"
    entry_point = "helloPubSub" # Set the entry point
   
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    
    service_account_email    = var.service_account_email
  }

  event_trigger {
    trigger_region = "us-central1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}


resource "google_logging_metric" "logging_metric" {
  name   = var.log_metric
  filter = "(resource.type = cloud_function resource.labels.function_name = scc-alerts resource.labels.region = us-central1) OR (resource.type = cloud_run_revision resource.labels.service_name = scc-alerts resource.labels.location = us-central1) severity>=DEFAULT textPayload=~\"Alert Found:\""
  metric_descriptor {
    unit        = 1
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "my_policy" {
  project = var.project_id
  display_name = var.alert_name
  combiner = "OR"
  conditions {
    display_name = "Log match condition"
    condition_matched_log {
      filter = google_logging_metric.logging_metric.filter

    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
    auto_close  = "1800s"
  }
  documentation{
    content = "> Click below url to access Security Command Center\n> https://console.cloud.google.com/security/command-center/threats?project=${var.project_id}"
    mime_type = "text/markdown"
  }

  notification_channels = [ var.notification_channels ]
}