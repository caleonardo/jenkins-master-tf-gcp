FROM jenkins/jenkins:lts
USER root
COPY jcac.yaml /var/jenkins_casc_configs/jcac.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Jenkins loads the JCAC config file in CASC_JENKINS_CONFIG:
ENV CASC_JENKINS_CONFIG="/var/jenkins_casc_configs/jcac.yaml"
