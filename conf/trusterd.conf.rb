#
# Trusterd - HTTP/2 Web Server scripting with mruby
#
# Copyright (c) MATSUMOTO, Ryosuke 2014 -
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
#

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
# # custom request headers
# # getter
# s.r.headers_in[":method"] #=> GET
# s.r.request_headers[":method"] #=> GET
#
# # custom response headers
# # getter
# s.r.headers_out["hoge] #=> fuga
# s.r.response_headers["hoge] #=> fuga
#
# # setter
# s.r.headers_out["hoge"] = fuga
# s.r.response_headers["hoge"] = fuga
#
#
# s.set_map_to_strage_cb {
#
#   p "callback bloack at set_map_to_strage_cb"
#   p s.request.uri          #=> /index.html
#   p s.request.filename     #=> /path/to/index.html
#   p s.request.unparsed_uri #=> /index.html?a=1&b=2
#   p s.request.args         #=> ?a=1&b=2
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
#   if s.request.uri =~ /hellocb/
#     s.set_content_cb {
#       s.rputs "hello trusterd world from cb"
#       s.echo "+ hello trusterd world from cb with \n"
#     }
#   end
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
#   f.write "#{s.conn.client_ip} #{Time.now} - #{s.r.uri} - #{s.r.filename}\n"
#
# }

s.run

