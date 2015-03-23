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
  :tls            => false,
  :callback       => true,
  :worker         => "auto",
  :debug          => true,

})

# log setup if you need
s.setup_access_log({
  :file   => "#{root_dir}/logs/access.log",
  :format => :default,
  :type   => :plain,
})

#
# callback config
#

# set map to storage phase
s.set_map_to_storage_cb do
  s.location ".*\.php$" do
    s.filename = s.document_root + "/index.html"
  end

  s.location "\/hello$" do
    # set content handler phase
    s.set_content_cb do
      s.echo "hello #{s.request_headers["user-agent"]} from #{s.conn.client_ip}, welcome to trusterd"
    end
  end

  s.location ".*\.rb$" do
    s.enable_shared_mruby
  end
end

# set access checker phase
s.set_access_checker_cb do
  s.file "#{s.document_root}/index.cgi" do
    s.set_status 403
  end
end

# set fixups phase which is mostly set response headers
s.set_fixups_cb do
  s.response_headers["last"] = "OK"
  s.response_headers["server"] = "change_server"
  if ! s.body.nil?
    s.response_headers["post-data"] = s.body
  end
end

# set logging phase
s.set_logging_cb do

  s.write_access_log

end

s.run
