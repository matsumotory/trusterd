#
# Dockerfile for Trusterd on ubuntu 14.04 64bit
#

#
# Using Docker Image matsumotory/trusterd
#
# Pulling
#   docker pull matsumotory/trusterd
#
# Running
#  docker run -d -p 8080:8080 matsumotory/trusterd
#
# Access
#   nghttp -v http://127.0.0.1:8080/index.html
#

#
# Manual Build
#
# Building
#   docker build -t local/trusterd .
#
# Running
#   docker run -d -p 8080:8080 local/trusterd
#
# Access
#   nghttp -v http://127.0.0.1:8080/index.html
#

FROM ubuntu:14.04
MAINTAINER matsumotory

RUN apt-get -y update
RUN apt-get -y install sudo openssh-server git curl rake bison \
    libcurl4-openssl-dev autoconf automake autotools-dev libtool \
    pkg-config zlib1g-dev libcunit1-dev libssl-dev libxml2-dev \
    libevent-dev libjansson-dev libjemalloc-dev cython python3.4-dev make g++ \
    python-setuptools

RUN cd /usr/local/src/ && git clone --depth 1 https://github.com/h2o/qrintf.git
RUN cd /usr/local/src/qrintf && make install PREFIX=/usr/local

RUN cd /usr/local/src/ && git clone --depth 1 git://github.com/matsumotory/trusterd.git
RUN cd /usr/local/src/trusterd && make && make install INSTALL_PREFIX=/usr/local/trusterd

EXPOSE 8080

ADD docker/conf /usr/local/trusterd/conf
ADD docker/conf/trusterd.conf.rb /usr/local/trusterd/conf/trusterd.conf.rb
ADD docker/htdocs /usr/local/trusterd/htdocs

# for FROM this image
ONBUILD ADD docker/conf /usr/local/trusterd/conf
ONBUILD ADD docker/conf/trusterd.conf.rb /usr/local/trusterd/conf/trusterd.conf.rb
ONBUILD ADD docker/htdocs /usr/local/trusterd/htdocs

# RUN chmod 755 /usr /usr/local
# CMD ["sudo", "-u", "daemon", "/usr/local/trusterd/bin/trusterd", "/usr/local/trusterd/conf/trusterd.conf.rb"]
#
# Docker Hub Bug? /usr/local permission is invalid
#
# d--x--x---  19 root root 4096 Aug  8 15:08 local
#
# exec root owner for now

WORKDIR /usr/local/trusterd
ENTRYPOINT ["./bin/trusterd"]
CMD ["./conf/trusterd.conf.rb"]
