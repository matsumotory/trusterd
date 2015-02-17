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

s.set_map_to_strage_cb do

  s.location ".*\.php$" do
    s.filename = s.document_root + "/index.html"
  end

  s.location "\/hello$" do
    s.set_content_cb {
      s.echo "hello #{s.request_headers["user-agent"]} from #{s.conn.client_ip}, welcome to trusterd"
    }
  end

  s.location ".*\.rb$" do
    s.enable_shared_mruby
  end

end

s.set_access_checker_cb do
  s.file "#{s.document_root}/index.cgi" do
    s.set_status 403
  end
end

s.set_fixups_cb do
  s.response_headers["last"] = "OK"
  s.response_headers["server"] = "change_server"
  if ! s.body.nil?
    s.response_headers["post-data"] = s.body
  end
end

s.setup_access_log({
  :file   => "#{root_dir}/logs/access.log",
  :format => :default,
})

s.set_logging_cb do

  s.write_access_log

end

s.run
