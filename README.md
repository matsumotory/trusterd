# Trusterd HTTP/2 Web Server
Trusterd is a high performance HTTP/2 Web Server scripting with [mruby](https://github.com/mruby/mruby) using [nghttp2](https://github.com/tatsuhiro-t/nghttp2) and [mruby-http2](https://github.com/matsumoto-r/mruby-http2). You can get HTTP/2 Web Server quickly which is high permance and customizable with mruby.

## Benchmark
Please see [benchmark link](https://gist.github.com/matsumoto-r/9702123).

## TODO
This is a very early version, please test and report errors. Wellcome pull-request.
- support callback Ruby block to extend Web server functions
- more customizable Web server configration

## Quick install
#### Install mruby with mruby-http2
Please see [mruby-http2 page](https://github.com/matsumoto-r/mruby-http2).
#### Download trusterd
```bash
git clone https://github.com/matsumoto-r/mruby-http2.git
```
#### Write config ``bin/trusterd.rb``
```ruby
root_dir = "/usr/local/trusterd"

s = HTTP2::Server.new({
  :port           => 8080,
  :key            => "#{root_dir}/ssl/server.key",
  :crt            => "#{root_dir}/ssl/server.crt",
  :document_root  => "#{root_dir}/htdocs",
  :server_name    => "mruby-http2 server",

  #
  # optional config
  #

  # debug default: false
  # :debug  =>  true,

  # tls default: true
  # :tls => false,

  # damone default: false
  # :daemon => true,
})

s.run
```
#### Create directory and files
```bash
mkdir -p /usr/local/trusterd/{bin,htdocs,ssl}
cp ssl.key ssl.crt /usr/local/trusterd/ssl/.
cp bin/trusterd.rb /usr/local/trusterd/bin/.
echo hello trusterd world. > /usr/local/trusterd/htdocs/index.html
```
#### Run trusterd
```bash
mruby /usr/local/trusterd/bin/trusterd.rb
```
## Peformance
#####Max performance: 336681 req/s
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

finished in 2 sec, 970 millisec and 170 microsec, 336681 req/s, 8220 kbytes/s
requests: 1000000 total, 1000000 started, 1000000 done, 1000000 succeeded, 0 failed, 0 errored
status codes: 1000000 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 49003700 bytes total, 1600 bytes headers, 25000000 bytes data
```
Please see [details](https://gist.github.com/matsumoto-r/9702123).
## License
under the MIT License:

* http://www.opensource.org/licenses/mit-license.php

