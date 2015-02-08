#include <stdio.h>
#include "mruby.h"
#include "mruby/compile.h"

const char config[] = "                                       \
                       HTTP2::Server.new({                    \
                           :port => 8080,                     \
                           :document_root => './',            \
                           :server_name => 'mini_trusterd',   \
                           :tls => false,                     \
                           :worker => 'auto',                 \
                       }).run                                 \
";

int main(void)
{
  mrb_state *mrb = mrb_open();
  mrb_load_string(mrb, config);
  mrb_close(mrb);
  return 0;
}
