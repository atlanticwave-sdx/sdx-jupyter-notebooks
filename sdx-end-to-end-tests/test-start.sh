#!/bin/bash

cd /home/fabric/work/_awsdx/sdx-deployment/awsdx-jupyter/fabric/sdx-end-to-end-tests

BRANCH=$1

if [ $# -lt 1 ]; then
   echo "--------------------------------------------------------------------------------"
   echo "--- Specify BRANCH: "
   echo "--------------------------------------------------------------------------------"
   echo "--- Use: '$0 e2e_tests_uc2' "
   echo "--------------------------------------------------------------------------------"
   exit 1;
fi

WORK_ORDER="$(date +"%Y%m%d-%H%M%S")"

NB_NAME="awsdx-e2e-branch1.ipynb"
NB_OUT="output-${BRANCH}-${NB_NAME}"
LOG_OUT="log-${BRANCH}-${NB_NAME}-${WORK_ORDER}.txt"

echo "--- Use NB: $NB_NAME"
echo "--- Use OUT: $NB_OUT"
echo "--- Use OUT: $LOG_OUT"

papermill -p sdx_end_to_end_tests_branch ${BRANCH} --log-output --stdout-file ${LOG_OUT} ${NB_NAME} ${NB_OUT}

