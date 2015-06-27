![logo](https://raw.githubusercontent.com/trusterd/trusterd/master/images/logo_full_white.png)

> Special thanks to @maybehelpy for creating trusterd logo!!

# Trusterd HTTP/2 Web Server

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/trusterd/trusterd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/trusterd/trusterd.svg?branch=master)](https://travis-ci.org/trusterd/trusterd)
[![wercker status](https://app.wercker.com/status/d389a8a05b263e469d51f40d532af04f/s "wercker status")](https://app.wercker.com/project/bykey/d389a8a05b263e469d51f40d532af04f)

[Trusterd](https://github.com/trusterd/trusterd) is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/trusterd/mruby-http2). You can get HTTP/2 Web Server quickly which is high performance and customizable with mruby. The HTTP/2 server and client function are pluggable. So, [you can embed these functions into your C applications](https://github.com/trusterd/trusterd/blob/master/README.md#embed-into-your-c-application).

## TODO
This is a very early version, please test and report errors. Welcome pull-request.
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

or comment out this line in `build_config.rb`

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

# use env value
debug_opt = (ENV["RELEASE"] == "production") ? false : true

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
  #:dh_params_file => "#{root_dir}/ssl/dh.pem",

  # listen ip address
  # default value is 0.0.0.0
  # :server_host  => "127.0.0.1",

  #
  # optional config
  #

  # debug default: false
  :debug  =>  debug_opt,

  # tls default: true
  :tls => false,

  # daemon default: false
  # :daemon => true,

  # callback default: false
  # :callback => true,

  # connection_record default: true
  # :connection_record => false,

  # running user, start server with root and change to run_user
  # :run_user => "daemon",

  # Tuning RLIMIT_NOFILE, start server with root and must set run_user instead of root
  # :rlimit_nofile => 65535,

  # Set TCP_NOPUSH (TCP_CORK) option
  # :tcp_nopush => true,

  # expand buffer size before writing packet. decrease the number of small packets. That may be usefull for TLS session
  # :write_packet_buffer_expand_size => 4096 * 4,

  # limit buffer size before writing packet. write packet beyond the value. That may be usefull for TLS session
  # :write_packet_buffer_limit_size => 4096,

  # measuring server status: default false
  # :server_status => true,

  # use reverse proxy methods: default false
  # :upstream => true,

})

#
# when :callback option is true,
#
# # custom request headers
# # getter
# s.r.headers_in[":method"] #=> GET
# s.r.request_headers[":method"] #=> GET
#
# # custom response headers
# # setter
# s.r.headers_out["hoge"] = fuga
# s.r.response_headers["hoge"] = fuga
#
# # getter
# s.r.headers_out["hoge] #=> fuga
# s.r.response_headers["hoge] #=> fuga
#
#
# s.set_map_to_storage_cb {
#
#   p "callback block at set_map_to_storage_cb"
#   p s.filename            #=> /path/to/index.html
#   p s.uri                 #=> /index.html
#   p s.unparsed_uri        #=> /index.html?a=1&b=2
#   p s.percent_encode_uri  #=> /index.html?id=%E3%83%9F%E3
#   p s.args                #=> ?a=1&b=2
#   p s.body                #=> "post data"
#   p s.method              #=> "GET"
#   p s.scheme              #=> "https"
#   p s.authority           #=> "matsumoto-r.jp"
#   p s.host                #=> "matsumoto-r.jp"
#   p s.hostname            #=> "matsumoto-r.jp"
#   p s.client_ip           #=> "192.168.12.5"
#   p s.document_root       #=> "/path/to/htdocs"
#   p s.user_agent          #=> "trusterd_client"
#
#   p "if :server_status is true, use server status method"
#   p "the number of total requesting stream #{s.total_stream_request}"
#   p "the number of total requesting session #{s.total_session_request}"
#   p "the number of current connected sessions #{s.connected_sessions}"
#   p "the number of current processing streams #{s.active_stream}"
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
#   # reverse proxy config
#   # receive front end with HTTP/2 and proxy upstream server with HTTP/1.x
#   # TODO: don't support connection with TLS to upstream server
#   #
#   # need :upstream => true
#
#   if s.request.uri =~ /^/$/
#     # upstream request uri default: /
#     s.upstream_uri = s.percent_encode_uri
#     s.upstream_host = "127.0.0.1"
#
#     # upstream port default: 80
#     #s.upstream_port = 8080
#
#     # upstream connection timeout default: 600 sec
#     #s.upstream_timeout = 100
#
#     # use keepalive default: true
#     #s.upstream_keepalive = false
#
#     # use HTTP/1.0 protocol default: HTTP/1.1
#     #s.upstream_proto_major = 1
#     #s.upstream_proto_minor = 0
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

# extend response just before send response
# s.set_fixups_cb {
#  s.r.response_headers["server"] = "other server"
#}

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

#
# or use access logging methods
#s.setup_access_log({
#  :file   => "/usr/local/trusterd/logs/access.log",
#
#  # :default or :custom
#  # if using :custom, set logging format to write_access_log method arg
#  # s.write_access_log "client_ip: #{s.client_ip}"
#  :format => :default,
#
#  # :plain or :json if using :default
#  :type   => :plain,
#})
#
#s.set_logging_cb {
#  s.write_access_log
#}
#


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
$ ${GIT_CLONE_DIR}/mruby/build/host/mrbgems/mruby-http2/nghttp2/src/nghttp -v http://127.0.0.1:8080/index.html
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
##### Running
You can run trusted directly.
```
$ docker run --rm local/trusterd --help
Usage: ./bin/trusterd [switches] programfile
  switches:
  -b           load and execute RiteBinary (mrb) file
  -c           check syntax only
  -e 'command' one line of script
  -v           print version number, then run in verbose mode
  --verbose    run in verbose mode
  --version    print the version
  --copyright  print the copyright
```
Run with default configuration. ([docker/conf/trusterd.conf.rb](./docker/conf/trusterd.conf.rb))
```
docker run -d -p 8080:8080 local/trusterd
```
Run with your configuration.
```
mkdir localconf
vi localconf/your_config.rb ## Write your configuration.
$ docker run -d -v `pwd`/localconf:/usr/local/trusterd/localconf -p 8080:8080 local/trusterd ./localconf/your_config.rb
```

##### Access
```
nghttp -v http://127.0.0.1:8080/index.html
```

## Embed into your C application
### HTTP/2 Server function
See [src/mini_trusterd.c](https://github.com/trusterd/trusterd/blob/master/src/mini_trusterd.c)

### HTTP/2 Client function
See [src/mini_trusterd_client.c](https://github.com/trusterd/trusterd/blob/master/src/mini_trusterd_client.c)

## Performance
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
500,000 requests/sec is very faster!!
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

