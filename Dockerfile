FROM quay.io/orgsync/java:1.8.0_66-b17

ENV FLINK_VERSION 1.1.0
ENV SCALA_VERSION 2.11
ENV FLINK_HOME /opt/flink

WORKDIR /code
RUN apt-get update \
    && apt-get install -y maven \
    && curl "http://www-us.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-src.tgz" | tar --strip-components=1 -xz \
    && tools/change-scala-version.sh $SCALA_VERSION \
    && mvn package -DskipTests -pl flink-dist \
    && mvn package -f flink-metrics/flink-metrics-statsd/pom.xml -DskipTests \
    && cp "/code/flink-metrics/flink-metrics-statsd/target/flink-metrics-statsd-${FLINK_VERSION}.jar" /code/build-target/lib/ \
    && mkdir -p $FLINK_HOME \
    && cd $FLINK_HOME \
    && cp -R /code/build-target/* $FLINK_HOME/ \
    && apt-get remove --purge -y maven \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.m2 /code \
    && sed -i -e "s/> \"\$out\" 2>&1 < \/dev\/null//g" $FLINK_HOME/bin/flink-daemon.sh \
    && sed -i -e "s/echo \$mypid >> \$pid/echo \$mypid >> \$pid \&\& wait/g" $FLINK_HOME/bin/flink-daemon.sh

WORKDIR $FLINK_HOME
COPY entrypoint.sh $FLINK_HOME/bin/

COPY log4j.properties $FLINK_HOME/conf/
COPY log4j.properties $FLINK_HOME/conf/log4j-cli.properties
COPY log4j.properties $FLINK_HOME/conf/log4j-yarn-session.properties

COPY logback.xml $FLINK_HOME/conf/
COPY logback.xml $FLINK_HOME/conf/logback-yarn.xml

ENV PATH $PATH:$FLINK_HOME/bin
ENV FLINK_DATA /var/flink

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
