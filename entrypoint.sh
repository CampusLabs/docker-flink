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

mkdir -p $BLOB_STORAGE_DIRECTORY
mkdir -p $JOBMANAGER_WEB_TMPDIR
mkdir -p $JOBMANAGER_WEB_UPLOAD_DIR
mkdir -p $TASKMANAGER_TMP_DIRS
mkdir -p $STATE_BACKEND_ROCKSDB_CHECKPOINTDIR

FLINK_CONFIG=$FLINK_HOME/conf/flink-conf.yaml

METRICS_SCOPE_OPERATOR=$METRICS_SCOPE_TM_OPERATOR
METRICS_SCOPE_TASK=$METRICS_SCOPE_TM_TASK

function write_config_file() {
  declare -A options
  while read o; do
    local env_var_name=$(echo $o | tr 'a-z' 'A-Z' | sed 's/[\.-]/_/g')
    options[$o]=${!env_var_name}
  done <$FLINK_HOME/options

  echo "writing config file to $FLINK_CONFIG"
  > $FLINK_CONFIG
  for property in "${!options[@]}"; do
    local value=${options[$property]}

    if [[ ! -z "$value" ]]; then
      echo "$property: $value" >> $FLINK_CONFIG
    fi
  done

  echo "$(cat $FLINK_CONFIG | sort)"
}

write_config_file

case $1 in
  (jobmanager)
    exec $FLINK_HOME/bin/jobmanager.sh start-foreground cluster 0.0.0.0
  ;;
  (taskmanager)
    exec $FLINK_HOME/bin/taskmanager.sh start-foreground
  ;;
  (*)
    $@
  ;;
esac

