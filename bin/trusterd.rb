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
