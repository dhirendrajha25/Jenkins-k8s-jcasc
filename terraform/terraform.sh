#!/bin/bash

export PROJECT_ID=jenkins-test-project
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/account.json"
terraform $1 -var-file=$2 $3
if [ "$1" = "apply" ] ; then
   export KUBECONFIG="$(terraform output kubeconfig_path)"
fi


