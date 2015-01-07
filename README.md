# Trusterd HTTP/2 Web Server

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/matsumoto-r/trusterd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/matsumoto-r/trusterd.svg?branch=master)](https://travis-ci.org/matsumoto-r/trusterd)
[![wercker status](https://app.wercker.com/status/d389a8a05b263e469d51f40d532af04f/s "wercker status")](https://app.wercker.com/project/bykey/d389a8a05b263e469d51f40d532af04f)

Trusterd is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/matsumoto-r/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby.

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- more customizable Web server configration
- Server Push

## Requirements

- [nghttp2 Requirements](https://github.com/tatsuhiro-t/nghttp2#requirements)
- [mruby-http2 Requirements](https://github.com/matsumoto-r/mruby-http2/blob/master/mrbgem.rake#L6)
- Trusterd Requirements
  - libjemalloc-dev
  - [qrintf-gcc](https://github.com/h2o/qrintf)
  - If you don't have jemalloc and qrintf-gcc, comment out these lines on [build_config.rb](https://github.com/matsumoto-r/trusterd/blob/master/build_config.rb#L34-L62)

After reading [.travis.yml](https://github.com/matsumoto-r/trusterd/blob/master/.travis.yml), you might easy to understand the install

## Quick install
### Manual Build
#### Install qrintf
Please see [qrintf-gcc](https://github.com/h2o/qrintf)

#### Install jemalloc
##### Ubuntu
```
sudo apt-get install libjemalloc-dev
```

#### Download trusterd
```
git clone https://github.com/matsumoto-r/trusterd.git
cd trusterd
```
#### Build trusterd
```bash
make
```
#### Install
```bash
make install INSTALL_PREFIX=/usr/local/trusterd
```
#### Write config ``$(INSTALL_PREFIX)/conf/trusterd.conf.rb``
```ruby
SERVER_NAME = "Trusterd"
SERVER_VERSION = "0.0.1"
SERVER_DESCRIPTION = "#{SERVER_NAME}/#{SERVER_VERSION}"

root_dir = "/usr/local/trusterd"

s = HTTP2::Server.new({

  #
  # required config
  #

  :port           => 8080,
  :document_root  => "#{root_dir}/htdocs",
  :server_name    => SERVER_DESCRIPTION,

  # support prefork only when linux kernel supports SO_REUSEPORT
  # :worker         => 4,

  # required when tls option is true.
  # tls option is true by default.
  #:key            => "#{root_dir}/ssl/server.key",
  #:crt            => "#{root_dir}/ssl/server.crt",

  # listen ip address
  # default value is 0.0.0.0
  # :server_host  => "127.0.0.1",

  #
  # optional config
  #

  # debug default: false
  # :debug  =>  true,

  # tls default: true
  :tls => false,

  # damone default: false
  # :daemon => true,

  # callback default: false
  # :callback => true,

  # connection_record defualt: true
  # :connection_record => false,

})

#
# when :callback option is true,
#
# s.set_map_to_strage_cb {
#
#   p "callback bloack at set_map_to_strage_cb"
#   p s.request.uri
#   p s.request.filename
#
#   # location setting
#   if s.request.uri == "/index.html"
#     s.request.filename = "#{root_dir}/htdocs/hoge"
#   end
#   p s.request.filename
#
#   # you can use regexp if you link regexp mrbgem.
#   # Or, you can use KVS like mruby-redis or mruby-
#   # vedis and so on.
#
#   # Experiment: reverse proxy config
#   # reciev front end with HTTP/2 and proxy upstream server with HTTP/1
#   # TODO: reciev/send headers transparently and support HTTP/2 at upstream
#
#   if s.request.uri =~ /^\/upstream(\/.*)/
#     s.upstream_uri = $1
#     s.upstream = “http://127.0.0.1“
#   end
#
#   # dynamic content with mruby
#   if s.request.filename =~ /^.*\.rb$/
#     s.enable_mruby
#   end
#
#   # dynamic content with mruby sharing mrb_state
#   if s.request.filename =~ /^.*\_shared.rb$/
#     s.enable_shared_mruby
#   end
#
#
# }

# s.set_content_cb {
#   s.rputs "hello trusterd world from cb"
#   s.echo "+ hello trusterd world from cb with \n"
# }

#
# f = File.open "#{root_dir}/logs/access.log", "a"
#
# s.set_logging_cb {
#
#   p "callback block after send response"
#   f.write "#{s.conn.client_ip} #{Time.now} - #{s.r.uri} - #{s.r.filename}\n"
#
# }

s.run
```
#### Run trusterd
```bash
make start INSTALL_PREFIX=/usr/local/trusterd
```

or

```bash
$(INSTALL_PREFIX)/bin/trusterd $(INSTALL_PREFIX)/conf/trusterd.conf.rb
```

#### Clean
```
make clean
```
#### Check by nghttp
[nghttp](https://github.com/tatsuhiro-t/nghttp2#nghttp---client) is a client tool for HTTP/2.
```
$ nghttp http://127.0.0.1:8080/index.html
hello trusterd world.
```

----

### Using Docker
#### Using Docker image
##### Pulling
```
docker pull matsumotory/trusterd
```
##### Running
```
docker run -d -p 8080:8080 matsumotory/trusterd
```
##### Access
```
nghttp -v http://127.0.0.1:8080/index.html
```
#### Docker Image Build
##### Building
```
docker build -t local/trusterd .
```
##### Runing
```
docker run -d -p 8080:8080 local/trusterd
```
##### Access
```
nghttp -v http://127.0.0.1:8080/index.html
```
## Peformance
### Machine

- Ubuntu14.04 on VMWare
- Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz 4core
- Memory 8GB

### Config
#### trusterd.conf.rb
```ruby
SERVER_NAME = "Trusterd"
SERVER_VERSION = "0.0.1"
SERVER_DESCRIPTION = "#{SERVER_NAME}/#{SERVER_VERSION}"

root_dir = "/usr/local/trusterd"

s = HTTP2::Server.new({

  :port           => 8081,
  :document_root  => "#{root_dir}/htdocs",
  :server_name    => SERVER_DESCRIPTION,
  :tls            => false,

})

s.run
```

### Benchmarks

[h2load](https://github.com/tatsuhiro-t/nghttp2#benchmarking-tool) is a benchmark tool for HTTP/2.

- use [h2o/h2o benchmark parameter](https://github.com/h2o/h2o#benchmarks)

__HTTP/2__

|Server \ size of content|6 bytes|4,096 bytes|
|------------------------|------:|----------:|
|nghttpd ([nghttpd @ ab1dd11](https://github.com/tatsuhiro-t/nghttp2/)) |116,285|59,330|
|tiny-nghttpd ([nghttpd @ ab1dd11](https://github.com/tatsuhiro-t/nghttp2/)) |196,653|104,483|
|[Trusterd @ 69c294f](https://github.com/matsumoto-r/trusterd) + [mruby-http2 @ 5301e29](https://github.com/matsumoto-r/mruby-http2) |202,910|89,699|
|[Trusterd @ 69c294f](https://github.com/matsumoto-r/trusterd) + [mruby-http2 @ 5301e29](https://github.com/matsumoto-r/mruby-http2) 4 process prefork mode|494,616| h2load saturation |
|[H2O @ 3de8911](https://github.com/h2o/h2o)           |216,664|     112,418|

## Memory
#### Startup
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     62085  0.0  0.0  46668  2288 pts/4    S+   16:41   0:00  |   \_ /usr/local/trusterd/bin/trusterd /usr/local/trusterd/conf/trusterd.conf.rb
```
#### After processing ten million request
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     62085 63.3  0.0  49200  5144 pts/4    S+   16:41   0:47  |   \_ /usr/local/trusterd/bin/trusterd /usr/local/trusterd/conf/trusterd.conf.rb
```
## License
under the MIT License:

* http://www.opensource.org/licenses/mit-license.php

