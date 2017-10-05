FROM jenkins/jenkins
ENV DOCKER_COMPOSE_VERSION=1.15.0
ENV TERRAFORM_VERSION=0.9.11
ENV ITEM_ROOTDIR=/tmp/
USER root
RUN apt-get update && \
	apt-get install -y sudo curl vim libltdl7
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

#Docker
RUN groupadd -g 999 docker && usermod -aG docker jenkins #HCoded Groups, need to be fixed
RUN curl --silent -sSL -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && \
	tar -xvzf docker-latest.tgz && mv docker/* /usr/bin/

#Docker-Compose
RUN curl --silent -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chown jenkins /usr/local/bin/docker-compose &&  chgrp docker /usr/local/bin/docker-compose && chmod 777 /usr/local/bin/docker-compose


COPY config/ssh-keys/*  /usr/share/jenkins/ref/.ssh/
RUN chown jenkins /usr/share/jenkins/ref/.ssh/* && \
	chmod 400 /usr/share/jenkins/ref/.ssh/id_rsa && \
	chmod 644 /usr/share/jenkins/ref/.ssh/id_rsa.pub && \
	chmod 644 /usr/share/jenkins/ref/.ssh/known_hosts

#Init Scripts
COPY init/*.groovy /usr/share/jenkins/ref/init.groovy.d/

#Add All Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/ref/plugins.txt | tr '\n' ' ')

#TF
RUN cd /tmp && \
	wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	cp terraform /usr/bin/terraform

USER jenkins
COPY ./config/FIRSTRUN.txt $JENKINS_HOME/FIRSTRUN.txt
#Mark as up to date
RUN echo "2.0" > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo "2.0" > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
