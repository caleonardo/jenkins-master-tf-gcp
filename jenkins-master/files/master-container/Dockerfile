FROM jenkins/jenkins:2.266
USER root
COPY jcac.yaml /var/jenkins_casc_configs/jcac.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN ["jenkins-plugin-cli", "--plugin-file", "/usr/share/jenkins/ref/plugins.txt"]
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Jenkins loads the JCAC config file in CASC_JENKINS_CONFIG:
ENV CASC_JENKINS_CONFIG="/var/jenkins_casc_configs/jcac.yaml"
