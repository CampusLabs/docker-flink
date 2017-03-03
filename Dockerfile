FROM frolvlad/alpine-oraclejdk8

ENV FLINK_VERSION 1.2.0
ENV HADOOP_VERSION 27
ENV SCALA_VERSION 2.11
ENV FLINK_HOME /opt/flink

ENV FILE_NAME flink-${FLINK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala_${SCALA_VERSION}
ENV ARCHIVE_NAME ${FILE_NAME}.tgz
ENV ARCHIVE_URL http://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/${ARCHIVE_NAME}
ENV CHECKSUM_URL $ARCHIVE_URL.sha
ENV DEPENDENCIES bash libstdc++ ncurses
ENV BUILD_PACKAGES curl

ENV LOGBACK_CLASSIC_JAR http://repo1.maven.org/maven2/ch/qos/logback/logback-classic/1.1.10/logback-classic-1.1.10.jar
ENV LOGBACK_CORE_JAR http://repo1.maven.org/maven2/ch/qos/logback/logback-core/1.1.10/logback-core-1.1.10.jar
ENV LOG4J_OVER_SLF4J_JAR http://repo1.maven.org/maven2/org/slf4j/log4j-over-slf4j/1.7.22/log4j-over-slf4j-1.7.22.jar

WORKDIR /flink
RUN apk --no-cache add $BUILD_PACKAGES $DEPENDENCIES \
  && curl $ARCHIVE_URL -o $ARCHIVE_NAME -s \
  && curl $CHECKSUM_URL -o $ARCHIVE_NAME.sha -s \
  && cat $ARCHIVE_NAME.sha | sha512sum -c \
  && tar -xzf $ARCHIVE_NAME \
  && mkdir -p $FLINK_HOME \
  && mv flink-$FLINK_VERSION/* $FLINK_HOME \
  && rm -Rf /flink \
  && cd /opt/flink/lib/ \
  && curl -O $LOGBACK_CLASSIC_JAR \
  && curl -O $LOGBACK_CORE_JAR \
  && curl -O $LOG4J_OVER_SLF4J_JAR \
  && rm log4j-1.2.17.jar slf4j-log4j12-1.7.7.jar \
  && cp /opt/flink/opt/flink-metrics-statsd-1.2.0.jar /opt/flink/lib \
  && apk del --purge $BUILD_PACKAGES \
  && sed -i -e "s/> \"\$out\" 200<&- 2>&1 < \/dev\/null &//" $FLINK_HOME/bin/flink-daemon.sh

WORKDIR /opt/flink
COPY entrypoint.sh $FLINK_HOME/bin/

COPY logback.xml $FLINK_HOME/conf/
COPY logback.xml $FLINK_HOME/conf/logback-yarn.xml

ENV PATH $PATH:$FLINK_HOME/bin
ENV FLINK_DATA /var/flink

ENV BLOB_SERVER_PORT                           6124
ENV BLOB_STORAGE_DIRECTORY                     $FLINK_DATA/blobs
ENV FS_DEFAULT_SCHEME                          file:///
ENV FS_OUTPUT_ALWAYS_CREATE_DIRECTORY          true
ENV HIGH_AVAILABILITY_JOBMANAGER_PORT          6123
ENV JOBMANAGER_HEAP_MB                         1024
ENV JOBMANAGER_RPC_ADDRESS                     jobmanager
ENV JOBMANAGER_RPC_PORT                        6123
ENV JOBMANAGER_WEB_PORT                        8081
ENV JOBMANAGER_WEB_UPLOAD_DIR                  $FLINK_DATA/jobs
ENV PARALLELISM_DEFAULT                        8
ENV RECOVERY_ZOOKEEPER_STORAGEDIR              $FLINK_DATA/recovery
ENV STATE_BACKEND_FS_CHECKPOINTDIR             $FLINK_DATA/checkpoints
ENV TASKMANAGER_DATA_PORT                      6121
ENV TASKMANAGER_RPC_PORT                       6122
ENV TASKMANAGER_HEAP_MB                        2048
ENV TASKMANAGER_NUMBEROFTASKSLOTS              8

ENV METRICS_REPORTERS                          stsd
ENV METRICS_REPORTER_STSD_CLASS                org.apache.flink.metrics.statsd.StatsDReporter
ENV METRICS_REPORTER_STSD_HOST                 localhost
ENV METRICS_REPORTER_STSD_PORT                 8125
ENV METRICS_SCOPE_JM                           flink.jobmanager
ENV METRICS_SCOPE_JM_JOB                       flink.jobmanager.<job_name>
ENV METRICS_SCOPE_TM                           flink.taskmanager
ENV METRICS_SCOPE_TM_JOB                       flink.taskmanager.<job_name>
ENV METRICS_SCOPE_TM_TASK                      flink.taskmanager.<job_name>.<subtask_index>
ENV METRICS_SCOPE_TM_OPERATOR                  flink.taskmanager.<job_name>.<operator_name>.<subtask_index>

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

# job, recovery, and checkpoint storage
VOLUME $FLINK_DATA

ENTRYPOINT ["entrypoint.sh"]
