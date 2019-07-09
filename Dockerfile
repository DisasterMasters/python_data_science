FROM ubuntu:18.04 as opencv-builder
MAINTAINER "Audris Mockus"

RUN apt update && DEBIAN_FRONTEND='noninteractive' apt install -y  curl gnupg apt-transport-https

#mongodb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.0.list

RUN apt-get update && apt-get install -y mongodb-org-shell openssh-server \
    lsof sudo sssd  sssd-tools git tmux  zsh  \
    wget ca-certificates \
    build-essential cmake pkg-config \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev gfortran \
    git curl vim python3-dev python3-pip \
    libfreetype6-dev libhdf5-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O opencv.tar.gz https://github.com/opencv/opencv/archive/3.3.1.tar.gz && \
    tar zxvf opencv.tar.gz && \
    wget -O opencv_contrib.tar.gz https://github.com/opencv/opencv_contrib/archive/3.3.1.tar.gz && \
    tar zxvf opencv_contrib.tar.gz

RUN cd opencv-3.3.1 && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.3.1/modules \
        -D BUILD_EXAMPLES=ON .. && \
    make -j4 && \
    make install && \
    ldconfig && \
    cd / && rm -Rf /opencv-3.3.1 /opencv_contrib-3.3.1

RUN pip3 install tensorflow && \
    pip3 install numpy pandas sklearn matplotlib seaborn jupyter pyyaml h5py && \
    pip3 install keras --no-deps && \
    pip3 install opencv-python && \
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
