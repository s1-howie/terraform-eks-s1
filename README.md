# terraform-eks-s1
A terraform template to create a basic EKS cluster and auto-install the SentinelOne Agent for K8s.

## Detailed Description

This terraform template is based on  [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster) and is designed to facilitate the creation of a 'vanilla' AWS EKS cluster for usage with testing/demos/etc.
It will create:
- A new AWS VPC which will contain all associated resources
- An EKS cluster with 2 worker nodes (by default)
- Create a new namespace to house the SentinelOne K8s resources
- Create a new K8s secret within the above-mentioned namespace that contains the credentials needed to pull the S1 images
- A helm deployment of the SentinelOne Agent for K8s

The template has a local-exec provisioner that will take care of setting the Kubernetes context.  It will also create a local file that can be used to set the KUBECONFIG environment variable in order to access the cluster via kubectl from your local MBP/Linux workstation.

# AWS Pre-Requisites
- An [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start) with the IAM permissions listed on the [EKS module documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)
- A configured AWS CLI
- AWS IAM Authenticator
- kubectl
- wget (required for the eks module)

# Local MBP/Linux workstation Pre-Requisites
- git v2.32+ (https://git-scm.com/downloads)
- terraform v0.14+ (https://www.terraform.io/downloads.html)
- awscli (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- kubectl v1.21+ (https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- helm 3.0+ (https://helm.sh/docs/intro/install/)
- wget 

On a MBP, you can easily install all of these pre-requisites with [homebrew](https://formulae.brew.sh/):
```
brew update && brew install git terraform awscli aws-iam-authenticator kubernetes-cli helm wget
```

# Setting up terraform to communicate with AWS
After you've installed the AWS CLI, configure it by running "aws configure".

When prompted, enter your AWS Access Key ID, Secret Access Key, region and output format.
```
$ aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: YOUR_AWS_REGION
Default output format [None]: json
```

If you don't have an AWS Access Credentials, create your AWS Access Key ID and Secret Access Key by navigating to your [service credentials](https://console.aws.amazon.com/iam/home?#/security_credentials) in the IAM service on AWS. Click "Create access key" here and download the file. This file contains your access credentials.

Your default region can be found in the AWS Web Management Console beside your username. Select the region drop down to find the region name (eg. us-east-1) corresponding with your location.


# Usage
1. Clone this repository
```
git clone https://github.com/s1-howie/terraform-eks-s1.git
```
2. Edit the variables in the sample 'terraform.tfvars.removeme' file to suit your environment

3. Remove the '.removeme' extension from terraform.tfvars.removeme so that the filename reads as: terraform.tfvars

4. Initialize terraform
```
terraform init
```
5. Run 'terraform apply' to execute the template
```
terraform apply
```
   This process typically takes 10-15 minutes.

6. Review the resources that will be created by the template and type "yes" to proceed.
   Once the template completes creating all resources, you should be able to use kubectl to manage your new cluster.
```
kubectl cluster-info
```
```
kubectl get nodes
```
```
kubectl get pods -A
```

# Cleaning up
After you've finished with your cluster, you can destroy/delete it (to keep your AWS bill as low as possible)
```
terraform destroy -auto-approve
```
   This process typically takes 10-15 minutes.