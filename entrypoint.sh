#!/bin/bash -e

################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

FLINK_CONFIG=$FLINK_HOME/conf/flink-conf.yaml

function write_config_file() {
  declare -A options
  options[akka.ask.timeout]="$AKKA_ASK_TIMEOUT"
  options[akka.framesize]="$AKKA_FRAMESIZE"
  options[akka.log.lifecycle.events]="$AKKA_LOG_LIFECYCLE_EVENTS"
  options[akka.lookup.timeout]="$AKKA_LOOKUP_TIMEOUT"
  options[akka.startup-timeout]="$AKKA_STARTUP_TIMEOUT"
  options[akka.tcp.timeout]="$AKKA_TCP_TIMEOUT"
  options[akka.throughput]="$AKKA_THROUGHPUT"
  options[akka.transport.heartbeat.interval]="$AKKA_TRANSPORT_HEARTBEAT_INTERVAL"
  options[akka.transport.heartbeat.pause]="$AKKA_TRANSPORT_HEARTBEAT_PAUSE"
  options[akka.transport.threshold]="$AKKA_TRANSPORT_THRESHOLD"
  options[akka.watch.heartbeat.interval]="$AKKA_WATCH_HEARTBEAT_INTERVAL"
  options[akka.watch.heartbeat.pause]="$AKKA_WATCH_HEARTBEAT_PAUSE"
  options[akka.watch.threshold]="$AKKA_WATCH_THRESHOLD"
  options[blob.fetch.backlog]="$BLOB_FETCH_BACKLOG"
  options[blob.fetch.num-concurrent]="$BLOB_FETCH_NUM_CONCURRENT"
  options[blob.fetch.retries]="$BLOB_FETCH_RETRIES"
  options[blob.server.port]="$BLOB_SERVER_PORT"
  options[blob.storage.directory]="$BLOB_STORAGE_DIRECTORY"
  options[compiler.delimited-informat.max-line-samples]="$COMPILER_DELIMITED_INFORMAT_MAX_LINE_SAMPLES"
  options[compiler.delimited-informat.max-sample-len]="$COMPILER_DELIMITED_INFORMAT_MAX_SAMPLE_LEN"
  options[compiler.delimited-informat.min-line-samples]="$COMPILER_DELIMITED_INFORMAT_MIN_LINE_SAMPLES"
  options[env.java.home]="$ENV_JAVA_HOME"
  options[env.java.opts]="$ENV_JAVA_OPTS"
  options[env.java.opts.jobmanager]="$ENV_JAVA_OPTS_JOBMANAGER"
  options[env.java.opts.taskmanager]="$ENV_JAVA_OPTS_TASKMANAGER"
  options[env.log.dir]="$ENV_LOG_DIR"
  options[fs.default-scheme]="$FS_DEFAULT_SCHEME"
  options[fs.hdfs.hadoopconf]="$FS_HDFS_HADOOPCONF"
  options[fs.hdfs.hdfsdefault]="$FS_HDFS_HDFSDEFAULT"
  options[fs.hdfs.hdfssite]="$FS_HDFS_HDFSSITE"
  options[fs.output.always-create-directory]="$FS_OUTPUT_ALWAYS_CREATE_DIRECTORY"
  options[fs.overwrite-files]="$FS_OVERWRITE_FILES"
  options[jobmanager.heap.mb]="$JOBMANAGER_HEAP_MB"
  options[jobmanager.rpc.address]="$JOBMANAGER_RPC_ADDRESS"
  options[jobmanager.rpc.port]="$JOBMANAGER_RPC_PORT"
  options[jobmanager.web.backpressure.cleanup-interval]="$JOBMANAGER_WEB_BACKPRESSURE_CLEANUP_INTERVAL"
  options[jobmanager.web.backpressure.delay-between-samples]="$JOBMANAGER_WEB_BACKPRESSURE_DELAY_BETWEEN_SAMPLES"
  options[jobmanager.web.backpressure.num-samples]="$JOBMANAGER_WEB_BACKPRESSURE_NUM_SAMPLES"
  options[jobmanager.web.backpressure.refresh-interval]="$JOBMANAGER_WEB_BACKPRESSURE_REFRESH_INTERVAL"
  options[jobmanager.web.checkpoints.disable]="$JOBMANAGER_WEB_CHECKPOINTS_DISABLE"
  options[jobmanager.web.checkpoints.history]="$JOBMANAGER_WEB_CHECKPOINTS_HISTORY"
  options[jobmanager.web.history]="$JOBMANAGER_WEB_HISTORY"
  options[jobmanager.web.port]="$JOBMANAGER_WEB_PORT"
  options[jobmanager.web.tmpdir]="$JOBMANAGER_WEB_TMPDIR"
  options[jobmanager.web.upload.dir]="$JOBMANAGER_WEB_UPLOAD_DIR"
  options[metrics.reporters]="$METRICS_REPORTERS"
  options[metrics.scope.jm]="$METRICS_SCOPE_JM"
  options[metrics.scope.jm.job]="$METRICS_SCOPE_JM_JOB"
  options[metrics.scope.tm]="$METRICS_SCOPE_TM"
  options[metrics.scope.tm.job]="$METRICS_SCOPE_TM_JOB"
  options[metrics.scope.tm.operator]="$METRICS_SCOPE_TM_OPERATOR"
  options[metrics.scope.tm.task]="$METRICS_SCOPE_TM_TASK"
  options[parallelism.default]="$PARALLELISM_DEFAULT"
  options[recovery.job.delay]="$RECOVERY_JOB_DELAY"
  options[recovery.mode]="$RECOVERY_MODE"
  options[recovery.zookeeper.client.connection-timeout]="$RECOVERY_ZOOKEEPER_CLIENT_CONNECTION_TIMEOUT"
  options[recovery.zookeeper.client.max-retry-attempts]="$RECOVERY_ZOOKEEPER_CLIENT_MAX_RETRY_ATTEMPTS"
  options[recovery.zookeeper.client.retry-wait]="$RECOVERY_ZOOKEEPER_CLIENT_RETRY_WAIT"
  options[recovery.zookeeper.client.session-timeout]="$RECOVERY_ZOOKEEPER_CLIENT_SESSION_TIMEOUT"
  options[recovery.zookeeper.path.latch]="$RECOVERY_ZOOKEEPER_PATH_LATCH"
  options[recovery.zookeeper.path.leader]="$RECOVERY_ZOOKEEPER_PATH_LEADER"
  options[recovery.zookeeper.path.namespace]="$RECOVERY_ZOOKEEPER_PATH_NAMESPACE"
  options[recovery.zookeeper.path.root]="$RECOVERY_ZOOKEEPER_PATH_ROOT"
  options[recovery.zookeeper.quorum]="$RECOVERY_ZOOKEEPER_QUORUM"
  options[recovery.zookeeper.storageDir]="$RECOVERY_ZOOKEEPER_STORAGEDIR"
  options[resourcemanager.rpc.port]="$RESOURCEMANAGER_RPC_PORT"
  options[restart-strategy]="$RESTART_STRATEGY"
  options[restart-strategy.failure-rate.delay]="$RESTART_STRATEGY_FAILURE_RATE_DELAY"
  options[restart-strategy.failure-rate.failure-rate-interval]="$RESTART_STRATEGY_FAILURE_RATE_FAILURE_RATE_INTERVAL"
  options[restart-strategy.failure-rate.max-failures-per-interval]="$RESTART_STRATEGY_FAILURE_RATE_MAX_FAILURES_PER_INTERVAL"
  options[restart-strategy.fixed-delay.attempts]="$RESTART_STRATEGY_FIXED_DELAY_ATTEMPTS"
  options[restart-strategy.fixed-delay.delay]="$RESTART_STRATEGY_FIXED_DELAY_DELAY"
  options[state.backend]="$STATE_BACKEND"
  options[state.backend.fs.checkpointdir]="$STATE_BACKEND_FS_CHECKPOINTDIR"
  options[task.cancellation-interval]="$TASK_CANCELLATION_INTERVAL"
  options[taskmanager.data.port]="$TASKMANAGER_DATA_PORT"
  options[taskmanager.debug.memory.logIntervalMs]="$TASKMANAGER_DEBUG_MEMORY_LOGINTERVALMS"
  options[taskmanager.debug.memory.startLogThread]="$TASKMANAGER_DEBUG_MEMORY_STARTLOGTHREAD"
  options[taskmanager.heap.mb]="$TASKMANAGER_HEAP_MB"
  options[taskmanager.hostname]="$TASKMANAGER_HOSTNAME"
  options[taskmanager.log.path]="$TASKMANAGER_LOG_PATH"
  options[taskmanager.memory.fraction]="$TASKMANAGER_MEMORY_FRACTION"
  options[taskmanager.memory.off-heap]="$TASKMANAGER_MEMORY_OFF_HEAP"
  options[taskmanager.memory.preallocate]="$TASKMANAGER_MEMORY_PREALLOCATE"
  options[taskmanager.memory.segment-size]="$TASKMANAGER_MEMORY_SEGMENT_SIZE"
  options[taskmanager.memory.size]="$TASKMANAGER_MEMORY_SIZE"
  options[taskmanager.network.numberOfBuffers]="$TASKMANAGER_NETWORK_NUMBEROFBUFFERS"
  options[taskmanager.numberOfTaskSlots]="$TASKMANAGER_NUMBEROFTASKSLOTS"
  options[taskmanager.rpc.port]="$TASKMANAGER_RPC_PORT"
  options[taskmanager.runtime.hashjoin-bloom-filters]="$TASKMANAGER_RUNTIME_HASHJOIN_BLOOM_FILTERS"
  options[taskmanager.runtime.max-fan]="$TASKMANAGER_RUNTIME_MAX_FAN"
  options[taskmanager.runtime.sort-spilling-threshold]="$TASKMANAGER_RUNTIME_SORT_SPILLING_THRESHOLD"
  options[taskmanager.tmp.dirs]="$TASKMANAGER_TMP_DIRS"
  options[yarn.application-attempts]="$YARN_APPLICATION_ATTEMPTS"
  options[yarn.application-master.port]="$YARN_APPLICATION_MASTER_PORT"
  options[yarn.containers.vcores]="$YARN_CONTAINERS_VCORES"
  options[yarn.heap-cutoff-min]="$YARN_HEAP_CUTOFF_MIN"
  options[yarn.heap-cutoff-ratio]="$YARN_HEAP_CUTOFF_RATIO"
  options[yarn.heartbeat-delay]="$YARN_HEARTBEAT_DELAY"
  options[yarn.maximum-failed-containers]="$YARN_MAXIMUM_FAILED_CONTAINERS"
  options[yarn.properties-file.location]="$YARN_PROPERTIES_FILE_LOCATION"

  echo "writing config file to $FLINK_CONFIG"
  > $FLINK_CONFIG
  for property in "${!options[@]}"; do
    local value=${options[$property]}

    if [[ ! -z "$value" ]]; then
      echo "$property: $value" >> $FLINK_CONFIG
    fi
  done
  echo "$(cat $FLINK_CONFIG)"
}

write_config_file

if [ "$1" = "jobmanager" ]; then
  exec $FLINK_HOME/bin/jobmanager.sh start cluster
elif [ "$1" = "taskmanager" ]; then
  exec $FLINK_HOME/bin/taskmanager.sh start
else
  $@
fi
