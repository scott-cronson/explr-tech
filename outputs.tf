output "airflow-uri" {
    value = google_composer_environment.airflow2.config[0].airflow_uri
}
