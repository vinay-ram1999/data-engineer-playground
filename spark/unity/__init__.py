from pyspark import SparkConf
import os

ICEBERG_REST_URI = os.environ["ICEBERG_REST_URI"]
UNITY_URI = os.environ["UNITY_URI"]
ICEBERG_ENDPOINT = os.environ["ICEBERG_ENDPOINT"]
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
AWS_S3_ENDPOINT = os.environ["AWS_S3_ENDPOINT"]
AWS_REGION = os.environ["AWS_REGION"]

conf = (
    SparkConf()
        .setAppName('spark_unity_catalog_delta_lake')
        .set(
        'spark.jars.packages',
        'io.delta:delta-spark_2.12:3.3.1,'
        'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.5.0,'
        'software.amazon.awssdk:bundle:2.29.52,'
        'org.slf4j:slf4j-simple:2.0.7,'
        'org.apache.hadoop:hadoop-aws:3.3.4,'
        'com.amazonaws:aws-java-sdk-bundle:1.12.365'
        )
        .set("spark.jars.excludes", "org.slf4j:slf4j-log4j12")
        .set(
            'spark.sql.extensions',
            'io.delta.sql.DeltaSparkSessionExtension,'
            'org.apache.iceberg.spark.extensions.IcebergSparkSessionExtension'
        )

        .set('spark.sql.catalog', 'org.apache.iceberg.spark.SparkSessionCatalog')
        .set('spark.sql.catalog.catalog-impl', 'org.apache.iceberg.rest.RESTCatalog')
        .set("spark.sql.catalog.type", "rest") 
        .set('spark.sql.catalog.uri', ICEBERG_REST_URI)
        .set('spark.sql.catalog.warehouse', ICEBERG_ENDPOINT)

        .set('spark.sql.catalog.s3.endpoint', AWS_S3_ENDPOINT)
        .set('spark.sql.catalog.s3.access-key-id', AWS_ACCESS_KEY_ID)
        .set('spark.sql.catalog.s3.secret-access-key', AWS_SECRET_ACCESS_KEY)
        .set('spark.sql.catalog.s3.path-style-access', 'true')
        .set('spark.sql.catalog.s3.region', AWS_REGION)

        .set('spark.hadoop.fs.s3a.endpoint', AWS_S3_ENDPOINT)
        .set('spark.hadoop.fs.s3a.path.style.access', 'true')
        .set('spark.hadoop.fs.s3a.connection.ssl.enabled', 'false')
        .set('spark.hadoop.fs.s3a.access.key', AWS_ACCESS_KEY_ID)
        .set('spark.hadoop.fs.s3a.secret.key', AWS_SECRET_ACCESS_KEY)
        .set('spark.hadoop.fs.s3a.region', AWS_REGION)
)

