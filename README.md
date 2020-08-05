# Automated kubernetes cluster setup and Jenkins Deployment 
The objective of this project is to use terraform in order to achieve an 
automated deployment of kubernetes cluster on google cloud and also to deploy Jenkins helm charts on the same cluster. 

## Tools and Technologies

- **Terraform** : Used to setup k8s on google cloud
- **Helm Charts** : Used to define templates and instructions to deploy Jenkins on k8s 
- **Git** : used to manage source code on github
- **kubectl** : used as a CLI to interact with the k8s cluster


## Objectives

- set up kubernetes cluster on google cloud(2 node kubernetes cluster)
- Jenkinks Master and worker configuration deployed on the GKE cluster using offical docker images for jenkins
- Configure a CI/CD Jenkins pipeline
- Install a helm chart(containing jenkins configuration) on the kubernetes cluster using terraform 

## Prerequisites to run the project 
-   **GCP account**: If you don’t have a GCP account, [create one now](https://console.cloud.google.com/freetrial/). This tutorial can be
    completed using only the services included in [GCP  Free Tier](https://cloud.google.com/free/).
-   **GCP project**: GCP organizes resources into projects. You can [create one](https://console.cloud.google.com/projectcreate) in the GCP Console.
    You need the project ID later in this tutorial.
-   **GCP service account key**: Terraform will access your GCP account by using a service account key. You
    can [create one](https://console.cloud.google.com/apis/credentials/serviceaccountkey) in the GCP Console. While creating the key, assign the role as **Project > Editor**.
-   **Google Kubernetes Engine API**: You can enable the Google Kubernetes Engine API for your project in
    the [GCP Console](https://console.developers.google.com/apis/api/container.googleapis.com).
-   **Terraform**: You can install Terraform with [these instructions](https://learn.hashicorp.com/terraform/gcp/install).
-   **Kubectl**: [Install Kubectl on your local machine to interact with the GKE](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Follow below steps to have the k8s cluster with Jenkins master-worker up and running - 

### Terraform commands
```
$ cd jenkins-k8s/terraform
$ terraform init
$ sh terraform.sh plan values.tfvars  #used to initialize a working directory containing Terraform configuration files
$ sh terraform.sh apply values.tfvars --auto-approve #used to create an execution plan for the resources such as kubernetes cluster, helm charts on google cloud.
```
### Check K8S resources

* You can check k8s resource on google kubernetes engine dashboard - refer [here](https://cloud.google.com/kubernetes-engine/docs/concepts/dashboards) for more details.
* Also , if you have kubectl installed on your local then you can connect to gke k8s cluster which you have created and use kubectl commands to view pods,services,nodes,namespaces,pvc,secrets . Refer [here](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands) for kubectl commands.

### Verify Jenkins deployment

The above deployment installed the Jenkins in the cluster. To check running master Jenkins , run :
```
kubectl get po
```

OR

check GKE dashboard.


You can get the external IP of the jenkins service. Run below command to view service:

```
kubectl get svc
```

OR

check GKE dashboard.

> Note: The Jenkins deployment uses a persistent volume claim that is mounted to /var/jenkins_home. This assures the data is saved across crashes, restarts, and upgrades.


#### Access Jenkins

Jenkins server is deployed in the cluster and can be accessed by copying the External-IP of service **jenkins-jenkins-k8s** and pasting into the browser. In the Login page, enter admin in username and password.

JENKINS URL = http://<External IP of service>

Jenkins page will come with Login button !!!

### Jenkins Slaves Configuration

We are using official cloudbees jenkins slave docker image - 

**Configuring the Jenkins Kubernetes Plugin** :-

We can now configure the plugin. Go to Manage Jenkins and select Configure System, scroll down to Cloud section at the bottom. Click on Add a new cloud and select Kubernetes, in the Kubernetes URL field, enter http:// followed by the cluster endpoint address of Kubernetes service. Next, in the Jenkins tunnel field, enter the IP address and port retrieved from the jenkins-jnlp service.

<add a image here>
    
Now, scroll down to the Images section at the bottom, click the Add Pod Template button.

Fill out the Name and Labels fields with unique values to identify the first agent. The label will specify which agent image should be used to run the build.The label will specify which agent image should be used to run the build.

<add a image here>
 
Next, in the Containers field, click on the Add Container button and select Container Template. In the section that appears, fill out the following fields:

docker image : cloudbees/jnlp-slave-with-java-build-tools:latest

<add a image here>

Click on the Save button at the bottom to save the changes and continue.

--- configure install automatically npm---


Create a new build job to ensure that Jenkins can scale on top of Kubernetes. On the main Jenkins page, click New Item and enter the name of the job. Select the Freestyle Project and click on the OK button.

On the next page, in the Label Expression field, type the label set for the Jenkins agent image(Ex- Jenkins-slave). Scroll down to the Build Environment section and the Build section, click Add build step and select Execute shell. Paste the command or script in the text box that appears:

<add a image here>
    
Click on the Save button when finished.

Now, go to the home screen and start the job just created by clicking on the Build Now icon. As soon as the job starts, after a few seconds, the pod will begin to create to execute the build.

<add a image here>


