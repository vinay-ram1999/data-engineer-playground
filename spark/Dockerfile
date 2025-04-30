# Base Image: Official Bitnami Spark 3.5.5
FROM bitnami/spark:3.5.5

# Switch to root user for installations
USER root

RUN mkdir -p /opt/bitnami/workspace

WORKDIR /opt/bitnami/workspace

RUN echo 'PYSPARK_PYTHON=/opt/bitnami/python' >> ~/.bashrc
RUN echo 'SPARK_MASTER_HOST=0.0.0.0' >> ~/.bashrc
RUN . ~/.bashrc

RUN pip install --upgrade pip
RUN pip install notebook
RUN pip install --upgrade --force-reinstall pyspark==3.5.5

EXPOSE 8888
EXPOSE 8080
EXPOSE 8081
EXPOSE 7077
EXPOSE 18080

CMD /bin/bash
