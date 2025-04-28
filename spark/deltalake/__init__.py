from pyspark import SparkConf
import os

NESSIE_URI = os.environ["NESSIE_URI"]
DELTA_LAKE_ENDPOINT = os.environ["DELTA_LAKE_ENDPOINT"]
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
AWS_S3_ENDPOINT = os.environ["AWS_S3_ENDPOINT"]
AWS_REGION = os.environ["AWS_REGION"]

conf = (
    SparkConf()
        .setAppName('spark_delta_lake')
        .set(
        'spark.jars.packages',
        'io.delta:delta-spark_2.12:3.3.1,'
        'org.projectnessie.nessie-integrations:nessie-spark-extensions-3.5_2.12:0.83.1,'
        'software.amazon.awssdk:bundle:2.29.52,'
        'org.slf4j:slf4j-simple:2.0.7,'
        'org.apache.hadoop:hadoop-aws:3.3.4,'
        'com.amazonaws:aws-java-sdk-bundle:1.12.365'
        )
        .set("spark.jars.excludes", "org.slf4j:slf4j-log4j12")
        .set(
            'spark.sql.extensions',
            'io.delta.sql.DeltaSparkSessionExtension,'
            'org.projectnessie.spark.extensions.NessieSparkSessionExtensions'
        )

        .set('spark.sql.catalog.nessie', 'org.apache.spark.sql.delta.catalog.DeltaCatalog')
        .set('spark.sql.catalog.nessie.uri', NESSIE_URI)
        .set('spark.sql.catalog.nessie.ref', 'main')
        .set('spark.sql.catalog.nessie.authentication.type', 'NONE')
        .set('spark.sql.catalog.nessie.catalog-impl', 'org.projectnessie.deltalake.NessieDeltaLakeCatalog')

        .set('spark.sql.catalog.nessie.warehouse', DELTA_LAKE_ENDPOINT)

        .set('spark.hadoop.fs.s3a.endpoint', AWS_S3_ENDPOINT)
        .set('spark.hadoop.fs.s3a.path.style.access', 'true')
        .set('spark.hadoop.fs.s3a.connection.ssl.enabled', 'false')
        .set('spark.hadoop.fs.s3a.access.key', AWS_ACCESS_KEY_ID)
        .set('spark.hadoop.fs.s3a.secret.key', AWS_SECRET_ACCESS_KEY)
        .set('spark.hadoop.fs.s3a.region', AWS_REGION)
)

