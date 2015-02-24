SERVER_NAME = "Trusterd"
SERVER_VERSION = "0.0.1"
SERVER_DESCRIPTION = "#{SERVER_NAME}/#{SERVER_VERSION}"

root_dir = "/usr/local/trusterd"

s = HTTP2::Server.new({

  :port           => 8080,
  :document_root  => "#{root_dir}/htdocs",
  :server_name    => SERVER_DESCRIPTION,
  :run_user => "matsumotory",

  :tls => false,

})

s.set_map_to_strage_cb {
#   # dynamic content with mruby
  if s.request.filename =~ /^.*\.rb$/
    s.enable_mruby
  end
}

s.run

