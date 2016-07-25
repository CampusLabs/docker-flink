FROM quay.io/orgsync/java:1.8.0_66-b17

ENV FLINK_HOME /opt/flink
WORKDIR /code
RUN apt-get update \
  && apt-get install -y git maven \
  && git clone https://github.com/apache/flink.git \
  && cd flink \
  && mvn package -DskipTests -pl flink-dist \
  && mkdir -p $FLINK_HOME \
  && cp -R /code/flink/build-target/* $FLINK_HOME/ \
  && apt-get remove --purge -y git maven \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.m2 /code \
  && sed -i -e "s/echo \$mypid >> \$pid/echo \$mypid >> \$pid \&\& wait/g" $FLINK_HOME/bin/flink-daemon.sh

COPY entrypoint.sh $FLINK_HOME/bin/
WORKDIR $FLINK_HOME
ENV PATH $PATH:$FLINK_HOME/bin

EXPOSE 6123
EXPOSE 8081

ENTRYPOINT ["entrypoint.sh"]
