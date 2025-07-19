{% macro run_word_count_sp() %}
{% set proc_name = var("spark_dataset") ~ ".word_count_proc" %}

{% set sp_sql %}
CREATE OR REPLACE PROCEDURE {{ proc_name }}()
EXTERNAL SECURITY INVOKER
WITH CONNECTION `{{ target.project }}.eu.{{ var("spark_connection") }}`
OPTIONS(engine="SPARK")
LANGUAGE PYTHON AS R"""
from pyspark.sql import SparkSession
from pyspark.sql import functions as f

spark = SparkSession.builder.appName("spark-bigquery-demo").getOrCreate()

# Load data from BigQuery.
words_df = spark.read.format("bigquery") \
.option("table", "bigquery-public-data:samples.shakespeare") \
.load()
 
# Perform word count.
word_count = words_df.groupBy("word").agg(f.sum("word_count").alias("total_word_count"))
word_count.show()
word_count.printSchema()

word_count.write \
.format("bigquery") \
.option("writeMethod", "direct") \
.save("{{var("spark_dataset")}}.wordcount_output_dbt", mode="overwrite")
print("Wrote to BigQuery")

word_count.coalesce(1).write.csv("gs://{{var("spark_gcs_bucket")}}/wordcount_output_dbt.csv", header=True, mode="overwrite")

print("Wrote to gcs")
"""
{% endset %}

{% do run_query(sp_sql) %}

{% set task_sql %}
SET @@spark_proc_properties.service_account='{{ var("spark_sa_prefix") }}@{{ target.project }}.iam.gserviceaccount.com';
SET @@spark_proc_properties.staging_dataset_id='{{ var("spark_dataset") }}';

CALL {{ proc_name }}();
{% endset %}
{{ log("Starting Spark procedure run.", info=True) }}
{% do run_query(task_sql) %}

{{ log("Finished Spark procedure run.", info=True) }}
{% endmacro %}
