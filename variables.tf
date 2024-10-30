variable "project_id" {
  description = "GCP project id"
  default = ""
}

variable "pubsub_topic" {
  default = "scc-alerts"
  description = "Pubsub topic name"
}

variable "function_name" {
  description = "Name of the Cloud Function"
  default = "scc-alerts"
}

variable "log_metric" {
  default = "scc-alerts"
}

variable "alert_name" {
  default = "Security Command Center Alerts"
  description = "Alert Name"
}

variable "service_account_email" {
  description = "IAM service account email for the Cloud Function"
}

variable "notification_channels" {
  default = ""
  description = "Notification channels ID of Slack channel"
} 

variable "function_source" {
  description = "source code path for Cloud Function "
}
