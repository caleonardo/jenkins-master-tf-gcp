#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/sh

echo "**** Startup Step  1/10: Update apt-get repositories. ****"
sudo apt-get update

echo "**** Startup Step  2/10: Install Docker: SET UP THE REPOSITORY. ****"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo "**** Startup Step  3/10: Install Docker: Add Docker official GPG key. ****"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"

echo "**** Startup Step  4/10: Install Docker: INSTALL DOCKER ENGINE. ****"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo mkdir /opt/jenkins-master && cd /opt/jenkins-master || exit

echo "**** Startup Step  5/10: Create the Dockerfile file. ****"
cat > /opt/jenkins-master/Dockerfile <<-EOT
${tpl_DOCKERFILE}
EOT

echo "**** Startup Step  6/10: Create the Jenkins-Configuration-As-Code (jcac.yaml) file. ****"
cat > /opt/jenkins-master/jcac.yaml <<-EOT
${tpl_JCAC_YAML}
EOT

echo "**** Startup Step  7/10: Create the Jenkins plugins file. ****"
cat > /opt/jenkins-master/plugins.txt <<-EOT
${tpl_PLUGINS_TXT}
EOT

echo "**** Startup Step  8/10: Building and running the Jenkins Master container. ****"
export TAG_NUMBER="0.1"

echo "**** Startup Step  9/10: Stop and delete the Master container if it exist. ****"
sudo docker container stop jenkins-master-container-$TAG_NUMBER
sudo docker container rm jenkins-master-container-$TAG_NUMBER

echo "**** Startup Step 10/10: Build & run the Master container. ****"
cd /opt/jenkins-master || exit
sudo docker build --tag jenkins_master_img:$TAG_NUMBER .
sudo docker run --publish 8080:8080 --detach --name jenkins-master-container-$TAG_NUMBER jenkins_master_img:$TAG_NUMBER

