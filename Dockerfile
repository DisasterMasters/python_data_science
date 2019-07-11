FROM ubuntu:18.04 as opencv-builder
MAINTAINER "Audris Mockusi based on Andrey Maksimov's Dockerfile"


RUN apt update && DEBIAN_FRONTEND='noninteractive' apt install -y  curl gnupg apt-transport-https

#mongodb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list

RUN apt-get update && apt-get install -y locale mongodb-org-shell openssh-server \
    lsof sudo sssd  sssd-tools git tmux  zsh  \
    wget ca-certificates \
    build-essential cmake pkg-config \
    libatlas-base-dev gfortran \
    git curl vim python3-dev python3-pip python3-tk \
    python3-yaml python3-msgpack \
    libfreetype6-dev libhdf5-dev && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN pip3 install --upgrade pip

RUN pip3 install tensorflow && \
    pip3 install numpy pandas sklearn matplotlib seaborn jupyter pyyaml h5py && \
    pip3 install keras --no-deps && \
    pip3 install imutils


COPY eecsCA_v3.crt /etc/ssl/ 
COPY sssd.conf /etc/sssd/ 
COPY common* /etc/pam.d/ 
RUN chmod 0600 /etc/sssd/sssd.conf /etc/pam.d/common* 
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; chmod 0755 /var/run/sshd; fi
COPY init.sh startsvc.sh startshell.sh notebook.sh startDef.sh /bin/
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && mkdir $HOME/.ssh && chown -R $NB_USER:users $HOME 
COPY id_rsa_gcloud.pub $HOME/.ssh/authorized_keys
RUN chown -R $NB_USER:users $HOME && chmod -R og-rwx $HOME/.ssh



#RUN ["mkdir", "notebooks"]
#COPY conf/.jupyter /root/.jupyter
#COPY run_jupyter.sh /

# Jupyter and Tensorboard ports
#EXPOSE 8888 6006

# Store notebooks in this mounted directory
#VOLUME /notebooks

#CMD ["/run_jupyter.sh"]
