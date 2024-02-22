## Google Cloud Platform security command center alerts

This project uses Terraform to set up a Google Cloud Platform (GCP) environment for Security Command Center alerts. The alerts will be notify through an existing Slack Channel.

## Features
- Sets up required providers for GCP.
- Creates a random ID for bucket prefix. (Bucket name must me globally unique)
- Enables [Eventarc API](https://cloud.google.com/eventarc/docs/reference/rest) for the project.
- Creates a Google Pub/Sub topic.
- Creates a Google Storage Bucket with a unique name.
- Uploads a zipped function source code to the created bucket.
- Binds the IAM role `roles/cloudfunctions.developer` to the project.
- Creates a Google Cloud Function (2nd gen).
- Sets up alert conditions and strategies.
- Alerts will be available in a Slack Channel.
- Provides a link to access the Security Command Center in the alert documentation.

## Google Cloud Resources

 Random ID for Bucket Prefix:
- Generates a random hex string to ensure a unique bucket name.

 Project Services Module:
- Enables the Eventarc API for the project.

 Pub/Sub Topic:
- Creates a Pub/Sub topic for event triggering.

 Cloud Storage Bucket:
- Creates a Cloud Storage bucket for storing the function source code.

 Cloud Storage Bucket Object:
- Uploads the specified function source code to the Cloud Storage bucket.

 IAM Role Binding:
- Binds the `cloudfunctions.developer` role to a service account for Cloud Functions.

 Cloud Function:
- Deploys a Cloud Function triggered by Pub/Sub messages.
- Configures build settings, service account, and event trigger.

 Logging Metric:
- Creates a Logging metric based on specified log filter conditions.

 Monitoring Alert Policy:
- Creates a Monitoring alert policy based on the Logging metric.
- Specifies notification channels and documentation URL.


## Usage
1. Make sure you have Terraform installed on your machine.
2. Clone this repository.
3. Navigate to the project directory.
4. Run `gcloud auth application-default login` to authenticate with GCP.
5. Update the `variables.tf` file with your project details.
6. Run `terraform init` to initialize your Terraform workspace.
7. Run `terraform apply` to create the resources on GCP.

### Example 

```
module "scc-alerts" {
  source                = "path_to_module"
  project_id            = "gcp_project_id"
  function_source       = "${path.module}/function-source.zip"
  service_account_email = "service_account_for_cloud_function"
  notification_channels = "slack_channel_id"
}
```

Please note that you need to have the appropriate permissions to create and manage the above resources in your GCP project.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Terraform Graph

![graph](images/graph.png)

This graph was generated using [Graphviz](https://graphviz.org/).