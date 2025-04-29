from pyspark import SparkConf
import os

NESSIE_URI = os.environ["NESSIE_URI"]
NESSIE_ENDPOINT = os.environ["NESSIE_ENDPOINT"]
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
AWS_S3_ENDPOINT = os.environ["AWS_S3_ENDPOINT"]
AWS_REGION = os.environ["AWS_REGION"]

conf = (
    SparkConf()
        .setAppName('spark_iceberg')
        .set(
        'spark.jars.packages',
        'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.8.1,'
        'org.projectnessie.nessie-integrations:nessie-spark-extensions-3.5_2.12:0.83.1,'
        'software.amazon.awssdk:bundle:2.29.52,'
        'org.slf4j:slf4j-simple:2.0.7,'
        'org.apache.hadoop:hadoop-aws:3.3.4,'
        'com.amazonaws:aws-java-sdk-bundle:1.12.365'
        )
        .set("spark.jars.excludes", "org.slf4j:slf4j-log4j12")
        .set(
            'spark.sql.extensions',
            'org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,'
            'org.projectnessie.spark.extensions.NessieSparkSessionExtensions'
        )
        # .set("iceberg.expire.tables.gc.enabled", "true")

        .set('spark.sql.catalog', 'org.apache.iceberg.spark.SparkSessionCatalog')
        .set('spark.sql.catalog.uri', NESSIE_URI)
        .set('spark.sql.catalog.ref', 'main')
        .set('spark.sql.catalog.authentication.type', 'NONE')
        .set('spark.sql.catalog.catalog-impl', 'org.apache.iceberg.nessie.NessieCatalog')

        .set('spark.sql.catalog.s3.endpoint', AWS_S3_ENDPOINT)
        .set('spark.sql.catalog.s3.path-style-access','true')
        .set('spark.sql.catalog.s3.access-key', AWS_ACCESS_KEY_ID)
        .set('spark.sql.catalog.s3.secret-key', AWS_SECRET_ACCESS_KEY)
        .set('spark.sql.catalog.s3.region', AWS_REGION)

        .set('spark.sql.catalog.warehouse', NESSIE_ENDPOINT)
        .set('spark.sql.catalog.io-impl', 'org.apache.iceberg.aws.s3.S3FileIO')

        .set('spark.hadoop.fs.s3a.endpoint', AWS_S3_ENDPOINT)
        .set('spark.hadoop.fs.s3a.path.style.access', 'true')
        .set('spark.hadoop.fs.s3a.connection.ssl.enabled', 'false')
        .set('spark.hadoop.fs.s3a.access.key', AWS_ACCESS_KEY_ID)
        .set('spark.hadoop.fs.s3a.secret.key', AWS_SECRET_ACCESS_KEY)
)

