provider "google" {
project = "project_id"
region = "asia-south1"
}

# -----------------------
# GCS BUCKET
# -----------------------
resource "google_storage_bucket" "aqi_bucket" {
name = "your_name_aqi-data-bucket"
location = "ASIA-SOUTH1"
force_destroy = true

uniform_bucket_level_access = true
}

# -----------------------
# BIGQUERY DATASET
# -----------------------
resource "google_bigquery_dataset" "aqi_dataset" {
dataset_id = "aqi_dataset"
location = "ASIA-SOUTH1"
delete_contents_on_destroy = true
}
