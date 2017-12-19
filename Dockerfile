FROM azul/zulu-openjdk-debian:8u152

ENV FLINK_MAJOR_VERSION=1.4 \
    HADOOP_VERSION=28 \
    SCALA_VERSION=2.11
ENV FLINK_VERSION=${FLINK_MAJOR_VERSION}.0
ENV FILE_NAME=flink-${FLINK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala_${SCALA_VERSION}
ENV FLINK_HOME=/opt/flink \
    ARCHIVE_NAME=${FILE_NAME}.tgz
ENV ARCHIVE_URL=http://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/${ARCHIVE_NAME}
ENV CHECKSUM_URL=$ARCHIVE_URL.sha \
    CONFIG_URL=https://raw.githubusercontent.com/apache/flink/release-${FLINK_MAJOR_VERSION}/docs/setup/config.md

WORKDIR /flink
RUN apt-get update \
  && apt-get install -yq gettext curl \
  && curl $ARCHIVE_URL -o $ARCHIVE_NAME -s \
  && curl $CHECKSUM_URL -o $ARCHIVE_NAME.sha -s \
  && cat $ARCHIVE_NAME.sha | sha512sum -c \
  && tar -xzf $ARCHIVE_NAME \
  && mkdir -p $FLINK_HOME \
  && mv flink-$FLINK_VERSION/* $FLINK_HOME \
  && rm -Rf /flink \
  && cp /opt/flink/opt/flink-metrics-statsd-${FLINK_VERSION}.jar /opt/flink/lib \
  && curl $CONFIG_URL -s | sed -n 's/^- `\([a-z\.-]*\)`.*/\1/p' | sort | uniq > $FLINK_HOME/options \
  && echo "taskmanager.numberOfTaskSlots" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.class" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.host" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.port" >> $FLINK_HOME/options \
  && echo "metrics.scope.operator" >> $FLINK_HOME/options \
  && echo "metrics.scope.task" >> $FLINK_HOME/options \
  && echo "high-availability.jobmanager.port" >> $FLINK_HOME/options \
  && rm -rf /var/lib/apt/lists/*

RUN cd /opt/flink/lib/ \
  && curl -O http://repo1.maven.org/maven2/ch/qos/logback/logback-classic/1.1.10/logback-classic-1.1.10.jar -s \
  && curl -O http://repo1.maven.org/maven2/ch/qos/logback/logback-core/1.1.10/logback-core-1.1.10.jar -s \
  && curl -O http://repo1.maven.org/maven2/org/slf4j/log4j-over-slf4j/1.7.22/log4j-over-slf4j-1.7.22.jar -s

WORKDIR /opt/flink
COPY entrypoint.sh $FLINK_HOME/bin/

COPY logback.xml $FLINK_HOME/conf/
COPY logback.xml $FLINK_HOME/conf/logback-yarn.xml

ENV PATH=$PATH:$FLINK_HOME/bin \
    FLINK_DATA=/var/flink \
    FLINK_TMP=/tmp/flink \
    BLOB_SERVER_PORT=6124 \
    FS_DEFAULT_SCHEME=file:/// \
    FS_OUTPUT_ALWAYS_CREATE_DIRECTORY=true \
    JOBMANAGER_HEAP_MB=1024 \
    JOBMANAGER_RPC_ADDRESS=jobmanager \
    JOBMANAGER_RPC_PORT=6123 \
    HIGH_AVAILABILITY_JOBMANAGER_PORT=6123 \
    JOBMANAGER_WEB_PORT=8081 \
    PARALLELISM_DEFAULT=1 \
    TASKMANAGER_DATA_PORT=6121 \
    TASKMANAGER_RPC_PORT=6122 \
    TASKMANAGER_HEAP_MB=2048 \
    TASKMANAGER_NUMBEROFTASKSLOTS=1 \
    TASKMANAGER_MEMORY_PREALLOCATE=true \
    METRICS_REPORTERS=stsd \
    METRICS_REPORTER_STSD_CLASS=org.apache.flink.metrics.statsd.StatsDReporter \
    METRICS_REPORTER_STSD_HOST=localhost \
    METRICS_REPORTER_STSD_PORT=8125 \
    METRICS_SCOPE_JM=flink.jobmanager \
    METRICS_SCOPE_JM_JOB=<job_name>.jobmanager \
    METRICS_SCOPE_TM=flink.taskmanager.<host> \
    METRICS_SCOPE_TM_JOB=<job_name>.taskmanager.<host> \
    METRICS_SCOPE_TM_TASK=<job_name>.task.<subtask_index>.<task_name> \
    METRICS_SCOPE_TM_OPERATOR=<job_name>.operator.<subtask_index>.<operator_name> \
    BLOB_STORAGE_DIRECTORY=$FLINK_TMP/blobs \
    JOBMANAGER_WEB_TMPDIR=$FLINK_TMP/web \
    JOBMANAGER_WEB_UPLOAD_DIR=$FLINK_TMP/web/upload \
    TASKMANAGER_TMP_DIRS=$FLINK_TMP/taskmanager \
    STATE_BACKEND_ROCKSDB_CHECKPOINTDIR=$FLINK_TMP/rocksdb \
    STATE_BACKEND=filesystem \
    ENV_JAVA_OPTS="-XX:ErrorFile=$FLINK_DATA/crash_%p.log" \
    ENV_LOG_DIR=$FLINK_DATA/log \
    HIGH_AVAILABILITY_ZOOKEEPER_STORAGEDIR=$FLINK_DATA/recovery \
    STATE_CHECKPOINTS_DIR=$FLINK_DATA/checkpoints/meta \
    STATE_BACKEND_FS_CHECKPOINTDIR=$FLINK_DATA/checkpoints/data

# taskmanager data
EXPOSE 6121

# taskmanager rpc
EXPOSE 6122

# jobmanager rpc
EXPOSE 6123

# jobmanager blob server port
EXPOSE 6124

# jobmanager web ui
EXPOSE 8081

# temp storage
VOLUME $FLINK_TMP

# recovery and checkpoint storage; must be shared across nodes for HA operation
VOLUME $FLINK_DATA

ENTRYPOINT ["entrypoint.sh"]
