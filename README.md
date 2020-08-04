# Automated kubernetes cluster setup and Jenkins Deployment 
Objective of this project is to achieve a automated deployment of k8s cluster on
google cloud and then deploy jenkins on that cluster using helm charts.

## Tools and Technologies used
* Terraform : Used to setup k8s on google cloud
* Helm Charts : Used to define templates and instructions to deploy Jenkins on k8s 
* git : used to manage source code on github
* kubectl : used as a CLI to interact with the k8s cluster


## Pre Requisites to run the Project 
* [Create Service account to access the k8s service using terrraform](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
* [Install Kubectl on your local machine to interact with the GKE](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Install helm on your local machine](https://helm.sh/docs/intro/install/)

## Helm Commands

```
helm create jenkins-k8s
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm install jenkins --render-subchart-notes
```


## Terraform commands
You can use the below format to use terraform commands
```
$ terraform $1 -var-file=$2 $3
```
```
$ sh terraform.sh init
$ sh terraform.sh plan
$ sh terraform.sh apply
$ sh terraform.sh destroy
```
