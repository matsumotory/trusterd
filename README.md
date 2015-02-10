# Trusterd HTTP/2 Web Server

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/trusterd/trusterd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/trusterd/trusterd.svg?branch=master)](https://travis-ci.org/trusterd/trusterd)
[![wercker status](https://app.wercker.com/status/d389a8a05b263e469d51f40d532af04f/s "wercker status")](https://app.wercker.com/project/bykey/d389a8a05b263e469d51f40d532af04f)

[Trusterd](https://github.com/trusterd/trusterd) is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/trusterd/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby. The HTTP/2 server and client function are pluggable. So, [you can embed these functions into your C applications](https://github.com/trusterd/trusterd/blob/master/README.md#embed-into-your-c-application).

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- more customizable Web server configration
- Server Push

## Requirements

- [nghttp2 Requirements](https://github.com/tatsuhiro-t/nghttp2#requirements)
- [mruby-http2 Requirements](https://github.com/trusterd/mruby-http2/blob/master/mrbgem.rake#L6)
- Trusterd Requirements
  - libjemalloc-dev
  - [qrintf-gcc](https://github.com/h2o/qrintf)
  - If you don't have jemalloc and qrintf-gcc, comment out these lines on [build_config.rb](https://github.com/trusterd/trusterd/blob/master/build_config.rb#L34-L62)
- If you use prefork mode, linux kernel need to support `SO_REUSEPORT`.

After reading [.travis.yml](https://github.com/trusterd/trusterd/blob/master/.travis.yml), you might easy to understand the install

## Quick install
### Manual Build
#### 1. Install qrintf (Optional, but recommended)
Please see [qrintf-gcc](https://github.com/h2o/qrintf)

or commet out this line in `build_config.rb`

```
cc.command = ENV['CC'] || 'qrintf-gcc'
```

#### 2. Install jemalloc (Optional, but recommended)
##### Ubuntu
```
sudo apt-get install libjemalloc-dev
```

or comment out this line in `build_config.rb`

```
linker.flags_after_libraries << '-ljemalloc'
```

#### 3. Download trusterd
```
git clone https://github.com/trusterd/trusterd.git
cd trusterd
```
#### 4. Build trusterd
```bash
make
```
#### 5. Install
```bash
make install INSTALL_PREFIX=/usr/local/trusterd
```
#### 6. Write config ``$(INSTALL_PREFIX)/conf/trusterd.conf.rb``
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

  # detect cpu thread automatically
  # If don't support SO_REUSEPORT of Linux, the number of worker is 0
  :worker         => "auto",

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

  # runngin user, start server with root and change to run_user
  # :run_user => "daemon",

  # Tuning RLIMIT_NOFILE, start server with root and must set run_user instead of root
  # :rlimit_nofile => 65535,

  # Set TCP_NOPUSH (TCP_CORK) option
  # :tcp_nopush => true,

  # expand buffer size before writing packet. decreace the number of small packets. That may be usefull for TLS session
  # :write_packet_buffer_expand_size => 4096 * 4,

  # limit buffer size before writing packet. write packet beyond the value. That may be usefull for TLS session
  # :write_packet_buffer_limit_size => 4096,

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
#  if s.request.uri =~ /hellocb/
#    s.set_content_cb {
#      s.rputs "hello trusterd world from cb"
#      s.echo "+ hello trusterd world from cb with \n"
#    }
#  end
#
# }

# #If define set_content_cb this scope, callback only once
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
#
#   f.write "client_ip:'#{s.conn.client_ip}' date:'#{s.r.date}' status:#{s.r.status} content_length:#{s.r.content_length} uri:'#{s.r.uri}' filename:'#{s.r.filename}' user_agent:'#{s.r.user_agent}'\n"
#
# }

s.run
```
#### 7. Run trusterd
```bash
make start INSTALL_PREFIX=/usr/local/trusterd
```

or

```bash
$(INSTALL_PREFIX)/bin/trusterd $(INSTALL_PREFIX)/conf/trusterd.conf.rb
```

#### 8. Check by nghttp
[nghttp](https://github.com/tatsuhiro-t/nghttp2#nghttp---client) is a client tool for HTTP/2.
```
$ nghttp http://127.0.0.1:8080/index.html
hello trusterd world.
```

#### Clean
```
make clean
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

## Embed into your C application
### HTTP/2 Server fucntion
See [src/mini_trusterd.c](https://github.com/trusterd/trusterd/blob/master/src/mini_trusterd.c)

### HTTP/2 Client function
See [src/mini_trusterd_client.c](https://github.com/trusterd/trusterd/blob/master/src/mini_trusterd_client.c)

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

#### 4 worker mode benchmark demo
500,000 reqeuat/sec is very fater!!
![](https://raw.githubusercontent.com/trusterd/trusterd/master/images/bench.png)

#### 4 worker mode cpu usage by top demo
trusterd worker processes use cpu resources of full core mostly.
![](https://raw.githubusercontent.com/trusterd/trusterd/master/images/top.png)

#### HTTP/2

|Server \ size of content|6 bytes|4,096 bytes|
|------------------------|------:|----------:|
|nghttpd ([nghttpd @ a08ce38](https://github.com/tatsuhiro-t/nghttp2/)) single thread|148,841|73,812|
|nghttpd ([nghttpd @ a08ce38](https://github.com/tatsuhiro-t/nghttp2/)) multi thread|347,152|104,244|
|tiny-nghttpd ([nghttpd @ a08ce38](https://github.com/tatsuhiro-t/nghttp2/)) single thread|190,223|82,047|
|[Trusterd @ 2432cc5](https://github.com/trusterd/trusterd) single process|204,769|92,068|
|[Trusterd @ 2432cc5](https://github.com/trusterd/trusterd) multi process|509,059| 134,542 |
|[H2O @ 529be4e](https://github.com/h2o/h2o) single thread          |216,453|     112,356|
|[H2O @ 529be4e](https://github.com/h2o/h2o) multi thread          |379,623|     146,343|

`h2load -c 500 -m 100 -n 2000000`


#### Ref: HTTP/1.1 on same benchmark environment

|Server \ size of content|6 bytes|4,096 bytes|
|------------------------|------:|----------:|
|nginx single process|21,708| 22,366 |
|nginx multi process|67,349| 56,203 |

`weighttp -k -c 500 -n 200000`


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

