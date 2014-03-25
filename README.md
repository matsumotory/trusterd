# Trusterd HTTP/2 Web Server
Trusterd is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/matsumoto-r/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby.

## Benchmark
Please see [benchmark link](https://gist.github.com/matsumoto-r/9702123).

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- more customizable Web server configration

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
#### Write config ``bin/trusterd.conf.rb``
```ruby
root_dir = "/usr/local/trusterd"

s = HTTP2::Server.new({

  :port           => 8080,
  #:key            => "#{root_dir}/ssl/server.key",
  #:crt            => "#{root_dir}/ssl/server.crt",
  :document_root  => "#{root_dir}/htdocs",
  :server_name    => "mruby-http2 server",

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
#####Max performance(2014/03/24): 284681 req/s
[h2load](https://github.com/tatsuhiro-t/nghttp2#benchmarking-tool) is a benchmark tool for HTTP/2.
```
$ h2load -n1000000 -c100 -m100 http://127.0.0.1:8080/index.html
starting benchmark...
spawning thread #0: 100 concurrent clients, 1000000 total requests
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

finished in 3 sec, 512 millisec and 701 microsec, 284681 req/s, 6950 kbytes/s
requests: 1000000 total, 1000000 started, 1000000 done, 1000000 succeeded, 0 failed, 0 errored
status codes: 1000000 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 49003700 bytes total, 1600 bytes headers, 25000000 bytes data

```
Please see [details](https://gist.github.com/matsumoto-r/9702123).
## License
under the MIT License:

* http://www.opensource.org/licenses/mit-license.php

