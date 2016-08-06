FROM quay.io/orgsync/java:1.8.0_66-b17

ENV FLINK_VERSION 1.1.0
ENV HADOOP_VERSION 27
ENV SCALA_VERSION 2.11
ENV FLINK_HOME /opt/flink
ENV FLINK_DATA /var/flink/

WORKDIR $FLINK_HOME
ENV ARCHIVE_NAME "flink-${FLINK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala_${SCALA_VERSION}.tgz"
RUN curl -O "http://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/${ARCHIVE_NAME}" \
    && tar --strip-components=1 -zxf $ARCHIVE_NAME \
    && rm $ARCHIVE_NAME \
    && sed -i -e "s/> \"\$out\" 2>&1 < \/dev\/null//g" $FLINK_HOME/bin/flink-daemon.sh \
    && sed -i -e "s/echo \$mypid >> \$pid/echo \$mypid >> \$pid \&\& wait/g" $FLINK_HOME/bin/flink-daemon.sh

ENV FLINK_SOURCE "http://repo1.maven.org/maven2/org/apache/flink"
ADD "${FLINK_SOURCE}/flink-metrics-statsd/${FLINK_VERSION}/flink-metrics-statsd-${FLINK_VERSION}.jar" $FLINK_HOME/lib/
ADD "${FLINK_SOURCE}/flink-statebackend-rocksdb_${SCALA_VERSION}/${FLINK_VERSION}/flink-statebackend-rocksdb_${SCALA_VERSION}-${FLINK_VERSION}.jar" $FLINK_HOME/lib/

COPY entrypoint.sh $FLINK_HOME/bin/

COPY log4j.properties $FLINK_HOME/conf/
COPY log4j.properties $FLINK_HOME/conf/log4j-cli.properties
COPY log4j.properties $FLINK_HOME/conf/log4j-yarn-session.properties

COPY logback.xml $FLINK_HOME/conf/
COPY logback.xml $FLINK_HOME/conf/logback-yarn.xml

ENV PATH $PATH:$FLINK_HOME/bin

VOLUME $FLINK_DATA

EXPOSE 6123
EXPOSE 8081

ENV STATSD_HOST localhost
ENV STATSD_PORT 8125

ENV FS_DEFAULT_SCHEME                          file:///
ENV FS_OUTPUT_ALWAYS_CREATE_DIRECTORY          true
ENV JOBMANAGER_HEAP_MB                         256
ENV JOBMANAGER_RPC_ADDRESS                     localhost
ENV JOBMANAGER_RPC_PORT                        6123
ENV JOBMANAGER_WEB_PORT                        8081
ENV JOBMANAGER_WEB_UPLOAD_DIR                  file://$FLINK_DATA/jobs
ENV METRICS_REPORTERS                          statsd
ENV PARALLELISM_DEFAULT                        8
ENV RECOVERY_ZOOKEEPER_STORAGEDIR              file://$FLINK_DATA/recovery
ENV STATE_BACKEND                              filesystem
ENV STATE_BACKEND_FS_CHECKPOINTDIR             file://$FLINK_DATA/checkpoints
ENV TASKMANAGER_HEAP_MB                        512
ENV TASKMANAGER_MEMORY_PREALLOCATE             false
ENV TASKMANAGER_NUMBEROFTASKSLOTS              8
ENV TASKMANAGER_RUNTIME_HASHJOIN_BLOOM_FILTERS true

ENTRYPOINT ["entrypoint.sh"]
