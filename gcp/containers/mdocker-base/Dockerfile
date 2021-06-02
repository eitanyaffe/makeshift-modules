# Ubuntu 20.04.1 LTS
FROM ubuntu:20.04

#############################################################################################
# basics
#############################################################################################

RUN apt-get update && apt-get install --no-install-recommends -y \
    lsb-release \
    curl \
    sudo \
    bash-completion \
    gnupg2 \
    python3.6 \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    wget \
    && apt-get clean all

#############################################################################################
# install docker
#############################################################################################

RUN wget -O docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-20.10.0.tgz && \
    tar --extract \
         --file docker.tgz \
	 --strip-components 1 \
	 --directory /usr/local/bin/ \
    && \
    rm docker.tgz
COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/

#############################################################################################
# gcsfuse
#############################################################################################

RUN GCSFUSE_REPO="gcsfuse-`lsb_release -c -s`"; echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install --no-install-recommends -y gcsfuse && apt-get clean all

#############################################################################################
# dsub
#############################################################################################

RUN pip3 install dsub

#############################################################################################
# local scripts
#############################################################################################

COPY mm mml /usr/local/bin
RUN chmod +x /usr/local/bin/mm /usr/local/bin/mml

#############################################################################################
# Install g++, gnumake, R
#############################################################################################

RUN apt-get install --no-install-recommends -y build-essential && apt-get clean all
RUN DEBIAN_FRONTEND="noninteractive" TZ="Europe/London" \
    apt-get install --no-install-recommends -y \
    dirmngr gnupg2 apt-transport-https ca-certificates software-properties-common \
    && apt-get clean all
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

RUN apt-get install --no-install-recommends -y r-base && apt-get clean all

RUN apt-get install --no-install-recommends -y x11-apps less

#############################################################################################
# gsutil
#############################################################################################

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz \
    && mkdir -p /usr/local/gcloud \
    && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
    && /usr/local/gcloud/google-cloud-sdk/install.sh \
    && rm /tmp/google-cloud-sdk.tar.gz

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

RUN sudo apt-get -y install gcc python3-dev python3-setuptools --no-install-recommends && \
    sudo pip3 uninstall crcmod && \
    sudo pip3 install --no-cache-dir -U crcmod && \
    sudo apt-get clean all

#############################################################################################
# extra command should be moved up
#############################################################################################

RUN sudo apt-get install -y --no-install-recommends time pigz && sudo apt-get clean all

#############################################################################################
# megahit
#############################################################################################

RUN mkdir -p /usr/local/megahit && \
    cd /usr/local/megahit && \
    wget https://github.com/voutcn/megahit/releases/download/v1.2.9/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
    tar zvxf MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && rm -rf MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz
ENV MEGAHIT_BIN /usr/local/megahit/MEGAHIT-1.2.9-Linux-x86_64-static/bin/megahit

#############################################################################################
# prodigal
#############################################################################################

RUN sudo apt-get install --no-install-recommends prodigal && \
    sudo apt-get clean all

#############################################################################################
# mapping
#############################################################################################

RUN sudo apt-get install --no-install-recommends -y bwa samtools && \
    sudo apt-get clean all

#############################################################################################
# sendgrid / khmer / sourmash
#############################################################################################

RUN pip3 install sendgrid khmer sourmash

#############################################################################################
# misc
#############################################################################################

RUN sudo apt-get install --no-install-recommends -y bc && \
    sudo apt-get clean all

#############################################################################################
# default command
#############################################################################################

CMD bash
