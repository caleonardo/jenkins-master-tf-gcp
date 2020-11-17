# Overview
 
This `jenkins-master-tf-gcp` Terraform module deploys a Jenkins Master in a container.

The Jenkins Master container runs inside a GCE instance in a new GCP project and uses the configuration as code provided in the `jcac.yaml` file

**WARNING: THE JENKINS MASTER DEPLOYED IS NOT MEANT TO BE A PRODUCTION SYSTEM.**

You could have a production-ready Jenkins Master if you:
 - Create your own SSH Public/Private keys
 - Set real values in the `jcac.yaml` file, especially for the `securityRealm` and `privateKey` sections

## Instructions

### Create a ssh private and public key pair with ssh-keygen

```
export tpl_JENKINS_AGENT_NAME=cft_agent
SSH_LOCAL_CONFIG_DIR="$HOME/.ssh"
mkdir "$SSH_LOCAL_CONFIG_DIR"
ssh-keygen -t rsa -m PEM -C "jenkins" -f "$SSH_LOCAL_CONFIG_DIR"/jenkins_"${tpl_JENKINS_AGENT_NAME}"_rsa
cat "$SSH_LOCAL_CONFIG_DIR"/jenkins"${tpl_JENKINS_AGENT_NAME}"_rsa
```

Copy the private key to `jenkins-master/files/master-container/sample-private-key.txt`
**Note:** The identantion **must** be the same as in the file (20 whitespaces) like:

```
-----BEGIN RSA PRIVATE KEY-----
                    your key
                    -----END RSA PRIVATE KEY-----
```

See the value of public key:

```
cat "$SSH_LOCAL_CONFIG_DIR"/jenkins"${tpl_JENKINS_AGENT_NAME}"_rsa.pub
```

Copy the public key to use as your Jenkins Agent public key.

### Set Terraform Variables in a terraform.tfvars file 

Use a `terraform.tfvars` file to setup at least the following variables:

```
org_id = "000000000000"
billing_account = "000000-000000-000000"
folder_id = "000000000000"
group_org_admins = "all-admin@yourdomain.com"
tpl_jenkins_agent_ip_addr = "xxx.xxx.xxx.xxx"
```

### Get credentials from gcloud

1. While developing only - Run `$ gcloud auth application-default login` before running `$ terraform plan` to avoid the errors below:
```
Error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
   on <empty> line 0:
  (source code not available)
```

### Run Terraform

``bash
cd jenkins-master/
terraform init
terraform plan
terraform apply
``

The module will create a GCP Project and a GCE instance, among other elements. Once the Instance is created, a container is deployed using the startup script, which might take around 5 to 10 minutes to complete.

When the startup script completes its job, you can open a browser window using the External IP of the newly created Jenkins Master on the port `8080` and using the username `admin` and password `admin` (as configures in the `securityRealm` section of the `jcac.yaml`) :
 - `http://External_IP:8080`

# TROUBLESHOOTING:

#### Login to the new GCE Instance using the SSH button in GCP
See the startup script logs in the GCE Instance with:
```
$ sudo cat /var/log/daemon.log | grep "startup-script"
```

#### Get into the Jenkins Master container:
 ```
 TAG_NUMBER=0.1
 sudo docker exec -ti jenkins-master-container-${TAG_NUMBER} /bin/bash
```

#### Configure SSH client in the Master
```
eval "$(ssh-agent -s)" && ssh-add /home/jenkins/.ssh/jenkinsAgent1_rsa && ssh-add -l
```

#### Try to connect to the Agent via SSH with verbose mode:
```
ssh -vvv -i /home/jenkins/.ssh/jenkinsAgent1_rsa.pub jenkins@JENKINS_AGENTIP_ADDR -p 22
```
