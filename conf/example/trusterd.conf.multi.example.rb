SERVER_NAME = "Trusterd"
SERVER_VERSION = "0.0.1"
SERVER_DESCRIPTION = "#{SERVER_NAME}/#{SERVER_VERSION}"

root_dir = "/usr/local/trusterd"
run_user = "matsumotory"

tls = HTTP2::Server.new({

  :port                            => 8080,
  :document_root                   => "#{root_dir}/htdocs",
  :server_name                     => SERVER_DESCRIPTION,

  :worker                          => "auto",
  :run_user                        => run_user,

  :rlimit_nofile                   => 65535,
  :write_packet_buffer_expand_size => 4096,
  :write_packet_buffer_limit_size  => 4096,

  :key                             => "#{root_dir}/ssl/server.key",
  :crt                             => "#{root_dir}/ssl/server.crt",

})

no_tls = HTTP2::Server.new({

  :port                            => 8081,
  :document_root                   => "#{root_dir}/htdocs",
  :server_name                     => SERVER_DESCRIPTION + "no_tls",

  :worker                          => 2,
  :run_user                        => run_user,

  :tls                             => false,

})

pid1 = Process.fork() { tls.run }
pid2 = Process.fork() { no_tls.run }

#sleep 5

Process.waitpid pid1
Process.waitpid pid2
