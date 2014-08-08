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
# Runing
#   docker run -d -p 8080:8080 local/trusterd
#
# Access
#   nghttp -v http://127.0.0.1:8080/index.html
#

FROM stackbrew/ubuntu:14.04
MAINTAINER matsumotory

RUN apt-get -y update
RUN apt-get -y install sudo
RUN apt-get -y install openssh-server
RUN apt-get -y install git
RUN apt-get -y install curl
RUN apt-get -y install rake
RUN apt-get -y install bison
RUN apt-get -y install libcurl4-openssl-dev
RUN apt-get -y install autoconf
RUN apt-get -y install automake
RUN apt-get -y install autotools-dev
RUN apt-get -y install libtool
RUN apt-get -y install pkg-config
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install libcunit1-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install libxml2-dev
RUN apt-get -y install libevent-dev
RUN apt-get -y install libjansson-dev
RUN apt-get -y install libjemalloc-dev
RUN apt-get -y install cython
RUN apt-get -y install python3.4-dev
RUN apt-get -y install make
RUN apt-get -y install g++

RUN cd /usr/local/src/ && git clone git://github.com/matsumoto-r/trusterd.git
RUN cd /usr/local/src/trusterd && sh build.sh
RUN cd /usr/local/src/trusterd && bash install.sh.example

EXPOSE 80

ADD docker/conf/trusterd.conf.rb /usr/local/trusterd/conf/trusterd.conf.rb

CMD ["sudo", "-u", "daemon", "/usr/local/trusterd/bin/trusterd", "/usr/local/trusterd/conf/trusterd.conf.rb"]
