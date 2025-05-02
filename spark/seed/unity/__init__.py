from pyspark import SparkConf
import os

UNITY_URI = os.environ["UNITY_URI"]
UNITY_SERVER = os.environ["UNITY_SERVER"]
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
        'io.unitycatalog:unitycatalog-spark_2.12:0.2.1,'
        'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.8.1,'
        'software.amazon.awssdk:bundle:2.29.52,'
        'org.slf4j:slf4j-simple:2.0.7,'
        'org.apache.hadoop:hadoop-aws:3.3.4,'
        'com.amazonaws:aws-java-sdk-bundle:1.12.365'
        )
        .set("spark.jars.excludes", "org.slf4j:slf4j-log4j12")
        .set(
            'spark.sql.extensions',
            'org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,'
            'io.delta.sql.DeltaSparkSessionExtension'
        )

        .set('spark.sql.catalog.spark_catalog', 'io.unitycatalog.spark.UCSingleCatalog')
        .set('spark.sql.catalog.unity', 'io.unitycatalog.spark.UCSingleCatalog')
        .set('spark.sql.catalog.unity.uri', UNITY_SERVER)
        .set('spark.sql.defaultCatalog', 'unity')
        # .set('spark.sql.catalog.unity.token', '') # this should match the ./unity/conf/token.txt every time the container is restarted
        # .set('spark.sql.catalog.unity.catalog-impl', 'org.apache.iceberg.rest.RESTCatalog')
        # .set('spark.sql.catalog.unity.type', 'rest')

        # .set('spark.sql.catalog.unity.s3.endpoint', AWS_S3_ENDPOINT)
        # .set('spark.sql.catalog.unity.s3.path-style-access', 'true')
        # .set('spark.sql.catalog.unity.s3.access-key-id', AWS_ACCESS_KEY_ID)
        # .set('spark.sql.catalog.unity.s3.secret-access-key', AWS_SECRET_ACCESS_KEY)
        # .set('spark.sql.catalog.unity.s3.region', AWS_REGION)

        # .set('spark.sql.catalog.unity.warehouse', ICEBERG_ENDPOINT)
        # .set('spark.sql.catalog.unity.io-impl', 'org.apache.iceberg.aws.s3.S3FileIO')
        .set('spark.sql.catalog.unity.io-impl', 'org.apache.iceberg.io.ResolvingFileIO') ####

        .set('spark.hadoop.fs.s3.impl', 'org.apache.hadoop.fs.s3a.S3AFileSystem')
        .set('spark.hadoop.fs.s3a.path.style.access', 'true')
        .set('spark.hadoop.fs.s3a.connection.ssl.enabled', 'false')
        .set('spark.hadoop.fs.s3a.endpoint', AWS_S3_ENDPOINT)
        .set('spark.hadoop.fs.s3a.access.key', AWS_ACCESS_KEY_ID)
        .set('spark.hadoop.fs.s3a.secret.key', AWS_SECRET_ACCESS_KEY)
)

