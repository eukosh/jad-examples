# Automating BigQuery Spark procedure in dbt
This repository demonstrates how to automate the execution of a BigQuery Spark procedure using dbt macros and including it in a GitHub Actions workflow.

## Prerequisites
- This repository uses service account, BigQuery external connection, GCS bucket, BigQuery dataset that were created in scope of this [blog post](https://medium.com/@eugene.kosharnyi/spark-stored-procedures-in-bigquery-a-practical-guide-that-works-6715fe700468).
- Ensure you have the Google Cloud SDK installed and configured.

## How to Use
1. Create Python virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
2. Authenticate with Google Cloud:
   ```bash
   gcloud auth application-default login
   ```
3. In `profiles.yml`, update the project ID to your project. Update service account if needed.
4. Take a look at the `dbt_project.yml` file and adjust the vars with your names.
5. Run the dbt command to execute the Spark procedure:
   ```bash
   dbt run-operation run_word_count_sp
   ```
