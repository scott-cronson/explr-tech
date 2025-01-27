terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }

}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "composer_worker_dev" {
  account_id   = "composer-worker-dev"
  display_name = "Composer-worker-dev" 
  description = "Composer Worker Dev service account"
}

resource "google_project_service" "composer_api" {
  project = var.project
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}

# https://cloud.google.com/composer/docs/composer-2/terraform-create-environments
resource "google_service_account" "composer_worker_tf" {
  account_id   = "composer-worker-tf"
  display_name = "Composer-worker-tf" 
  description = "Composer Worker service account"
}

# ENSURE USING "GOOGLE_PROJECT_IAM_MEMBER" INSTEAD OF "GOOGLE_SERVICE_ACCOUNT_IAM_MEMBER"
resource "google_project_iam_member" "composer-worker-iam" {
  project = var.project
  # service_account_id = google_service_account.composer_worker_tf.name
  role = "roles/composer.worker"
  member = "serviceAccount:${google_service_account.composer_worker_tf.email}"
}

resource "google_service_account_iam_member" "custom_service_account" {
  service_account_id = google_service_account.composer_worker_tf.name
  role = "roles/composer.ServiceAgentV2Ext"
  # member = "serviceAccount:${google_service_account.composer_worker_tf.email}"
  member = "serviceAccount:service-927621404250@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_composer_environment" "airflow2" {
  name = "composer-env"
  config {
    software_config {
      image_version = "composer-2-airflow-2"
    }
    environment_size = "ENVIRONMENT_SIZE_SMALL"
  
  node_config {
    service_account = google_service_account.composer_worker_tf.email
  }
  }
}

# https://cloud.google.com/composer/docs/composer-2/create-environments#grant-permissions