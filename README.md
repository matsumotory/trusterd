# Trusterd HTTP/2 Web Server

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/matsumoto-r/trusterd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/matsumoto-r/trusterd.svg?branch=master)](https://travis-ci.org/matsumoto-r/trusterd)
[![wercker status](https://app.wercker.com/status/d389a8a05b263e469d51f40d532af04f/s "wercker status")](https://app.wercker.com/project/bykey/d389a8a05b263e469d51f40d532af04f)

Trusterd is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/matsumoto-r/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby.

## Benchmark
Please see [benchmark link](https://gist.github.com/matsumoto-r/9702123).

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- more customizable Web server configration
- Server Push

## Quick install
### Manual Build
#### Download trusterd
```
git clone https://github.com/matsumoto-r/trusterd.git
```
#### Build trusterd
```bash
cd trusterd
sh build.sh
```
then, output ``bin/trusterd``
#### Write config ``conf/trusterd.conf.rb``
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
#### Create directory and files
```bash
mkdir -p /usr/local/trusterd/{bin,htdocs,ssl,conf}
cp bin/trusterd /usr/local/trusterd/bin/.
cp conf/trusterd.conf.rb /usr/local/trusterd/conf/.
echo hello trusterd world. > /usr/local/trusterd/htdocs/index.html
```
#### Run trusterd
```bash
/usr/local/trusterd/bin/trusterd /usr/local/trusterd/conf/trusterd.conf.rb
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

#### index.html
```html
hello trusterd world.
```

### Benchmark

[h2load](https://github.com/tatsuhiro-t/nghttp2#benchmarking-tool) is a benchmark tool for HTTP/2.

Current mruby-http2 commit: 9a98d6b1058cad866682fa51cf2d4110630bed63

```
$ h2load -w30 -W30 -n5000000 -c100 -m 100 http://127.0.0.1:8081/index.html
starting benchmark...
spawning thread #0: 100 concurrent clients, 5000000 total requests
progress: 10% done
progress: 20% done
progress: 30% done
progress: 40% done
progress: 50% done
progress: 60% done
progress: 70% done
progress: 80% done
progress: 90% done
progress: 100% done

finished in 32 sec, 773 millisec and 214 microsec, 152563 req/s, 8643 kbytes/s
requests: 5000000 total, 5000000 started, 5000000 done, 5000000 succeeded, 0 failed, 0 errored
status codes: 5000000 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 290084100 bytes total, 45081700 bytes headers, 110000000 bytes data
```

Please see [details](https://gist.github.com/matsumoto-r/9702123).

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

