FROM frolvlad/alpine-oraclejdk8

ENV FLINK_MAJOR_VERSION 1.2
ENV FLINK_VERSION ${FLINK_MAJOR_VERSION}.0
ENV HADOOP_VERSION 27
ENV SCALA_VERSION 2.11
ENV FLINK_HOME /opt/flink

ENV FILE_NAME flink-${FLINK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala_${SCALA_VERSION}
ENV ARCHIVE_NAME ${FILE_NAME}.tgz
ENV ARCHIVE_URL http://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/${ARCHIVE_NAME}
ENV CHECKSUM_URL $ARCHIVE_URL.sha
ENV CONFIG_URL https://raw.githubusercontent.com/apache/flink/release-${FLINK_MAJOR_VERSION}/docs/setup/config.md
ENV DEPENDENCIES bash libstdc++ ncurses ca-certificates
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
  && curl -O $LOGBACK_CLASSIC_JAR -s \
  && curl -O $LOGBACK_CORE_JAR -s \
  && curl -O $LOG4J_OVER_SLF4J_JAR -s \
  && rm log4j-1.2.17.jar slf4j-log4j12-1.7.7.jar \
  && cp /opt/flink/opt/flink-metrics-statsd-${FLINK_VERSION}.jar /opt/flink/lib \
  && curl $CONFIG_URL -s | sed -n 's/^- `\([a-z\.-]*\)`.*/\1/p' | sort | uniq > $FLINK_HOME/options \
  && echo "taskmanager.numberOfTaskSlots" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.class" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.host" >> $FLINK_HOME/options \
  && echo "metrics.reporter.stsd.port" >> $FLINK_HOME/options \
  && echo "metrics.scope.operator" >> $FLINK_HOME/options \
  && echo "metrics.scope.task" >> $FLINK_HOME/options \
  && echo "high-availability.jobmanager.port" >> $FLINK_HOME/options \
  && apk del --purge $BUILD_PACKAGES \
  && sed -i -e "s/> \"\$out\" 200<&- 2>&1 < \/dev\/null &//" $FLINK_HOME/bin/flink-daemon.sh

WORKDIR /opt/flink
COPY entrypoint.sh $FLINK_HOME/bin/

COPY logback.xml $FLINK_HOME/conf/
COPY logback.xml $FLINK_HOME/conf/logback-yarn.xml

ENV PATH $PATH:$FLINK_HOME/bin
ENV FLINK_DATA /var/flink
ENV FLINK_TMP /tmp/flink

ENV BLOB_SERVER_PORT                  6124
ENV FS_DEFAULT_SCHEME                 file:///
ENV FS_OUTPUT_ALWAYS_CREATE_DIRECTORY true
ENV JOBMANAGER_HEAP_MB                1024
ENV JOBMANAGER_RPC_ADDRESS            jobmanager
ENV JOBMANAGER_RPC_PORT               6123
ENV HIGH_AVAILABILITY_JOBMANAGER_PORT 6123
ENV JOBMANAGER_WEB_PORT               8081
ENV PARALLELISM_DEFAULT               1
ENV TASKMANAGER_DATA_PORT             6121
ENV TASKMANAGER_RPC_PORT              6122
ENV TASKMANAGER_HEAP_MB               2048
ENV TASKMANAGER_NUMBEROFTASKSLOTS     1
ENV TASKMANAGER_MEMORY_PREALLOCATE    true

ENV METRICS_REPORTERS                 stsd
ENV METRICS_REPORTER_STSD_CLASS       org.apache.flink.metrics.statsd.StatsDReporter
ENV METRICS_REPORTER_STSD_HOST        localhost
ENV METRICS_REPORTER_STSD_PORT        8125
ENV METRICS_SCOPE_JM                  flink.jobmanager
ENV METRICS_SCOPE_JM_JOB              <job_name>.jobmanager
ENV METRICS_SCOPE_TM                  flink.taskmanager.<host>
ENV METRICS_SCOPE_TM_JOB              <job_name>.taskmanager.<host>
ENV METRICS_SCOPE_TM_TASK             <job_name>.task.<subtask_index>.<task_name>
ENV METRICS_SCOPE_TM_OPERATOR         <job_name>.operator.<subtask_index>.<operator_name>

ENV BLOB_STORAGE_DIRECTORY              $FLINK_TMP/blobs
ENV JOBMANAGER_WEB_TMPDIR               $FLINK_TMP/web
ENV JOBMANAGER_WEB_UPLOAD_DIR           $FLINK_TMP/web/upload
ENV TASKMANAGER_TMP_DIRS                $FLINK_TMP/taskmanager
ENV STATE_BACKEND_ROCKSDB_CHECKPOINTDIR $FLINK_TMP/rocksdb

ENV STATE_BACKEND                          filesystem
ENV ENV_JAVA_OPTS                          -XX:ErrorFile=$FLINK_DATA/taskmanager_crash_%p.log
ENV ENV_LOG_DIR                            $FLINK_DATA/log
ENV HIGH_AVAILABILITY_ZOOKEEPER_STORAGEDIR $FLINK_DATA/recovery
ENV STATE_CHECKPOINTS_DIR                  $FLINK_DATA/checkpoints/meta
ENV STATE_BACKEND_FS_CHECKPOINTDIR         $FLINK_DATA/checkpoints/data

ENV TASKMANAGER_RUNTIME_HASHJOIN_BLOOM_FILTERS true

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
