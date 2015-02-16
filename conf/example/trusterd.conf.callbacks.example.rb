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
  :run_user       => "daemon",
  :worker         => "auto",
  :tls            => false,
  :callback       => true,
  :debug          => true,

})

#
# callback config
#

s.set_map_to_strage_cb {

  if s.r.uri =~ /.*\.php$/
    s.r.filename = s.document_root + "/index.html"
  end

  if s.r.uri =~ /\/hello$/
    s.set_content_cb {
      s.r.echo "hello #{s.r.request_headers["user-agent"]} from #{s.conn.client_ip}, welcome to trusterd"
    }
  end

  if s.r.uri =~ /.*\.rb$/
    s.enable_shared_mruby
  end
}

s.set_access_checker_cb {
  if s.r.filename == "#{s.document_root}/index.cgi"
    s.set_status 403
  end
}

s.set_fixups_cb {
  s.r.response_headers["last"] = "OK"
  s.r.response_headers["server"] = "change_server"
}

f = File.open "#{root_dir}/logs/access.log", "a"

s.set_logging_cb {

  f.write "client_ip:'#{s.conn.client_ip}' date:'#{s.r.date}' \
  status:#{s.r.status} content_length:#{s.r.content_length} uri:'#{s.r.uri}' \
  filename:'#{s.r.filename}' user_agent:'#{s.r.user_agent}'\n"

}

s.run
