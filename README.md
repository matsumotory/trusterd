# Trusterd HTTP/2 Web Server  [![Build Status](https://travis-ci.org/matsumoto-r/trusterd.svg?branch=master)](https://travis-ci.org/matsumoto-r/trusterd)
Trusterd is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/matsumoto-r/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby.

## Benchmark
Please see [benchmark link](https://gist.github.com/matsumoto-r/9702123).

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- more customizable Web server configration
- Server Push

## Quick install
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
## Peformance
[h2load](https://github.com/tatsuhiro-t/nghttp2#benchmarking-tool) is a benchmark tool for HTTP/2.
Current mruby-http2 commit: 49d213b0aeb82e6bc72169a0a43bafbaf909ee2a
```
$ h2load -w30 -W30 -n5000000 -c100 -m 100 http://127.0.0.1:8080/index.html
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

finished in 21 sec, 840 millisec and 430 microsec, 228933 req/s, 5815 kbytes/s
requests: 5000000 total, 5000000 started, 5000000 done, 5000000 succeeded, 0 failed, 0 errored
status codes: 5000000 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 250069900 bytes total, 20067800 bytes headers, 110000000 bytes data
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

