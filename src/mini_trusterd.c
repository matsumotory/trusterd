#include <stdio.h>
#include "mruby.h"
#include "mruby/compile.h"

const char config[] = "                                       \n\
                       s = HTTP2::Server.new({                \n\
                           :port => port,                     \n\
                           :document_root => './',            \n\
                           :server_name => 'mini_trusterd',   \n\
                           :tls => false,                     \n\
                           :callback => true,                 \n\
                           :worker => 'auto',                 \n\
                       })                                     \n\
";

const char response[] = "                                     \n\
                       s.set_map_to_strage_cb {               \n\
                         if s.request.uri =~ /hello/          \n\
                           s.set_content_cb {                 \n\
                             s.rputs 'hello mini-trusterd '   \n\
                             s.echo 'world from cb.'          \n\
                           }                                  \n\
                         end                                  \n\
                       }                                      \n\
";

const char run[] = "                                          \n\
                       s.run                                  \n\
";

int main(void)
{
  mrb_state *mrb = mrb_open();
  mrbc_context *ctx = mrbc_context_new(mrb);

  // 8080 into local variable "port" on same ctx
  mrb_load_string_cxt(mrb, "port = 8080", ctx);
  mrb_load_string_cxt(mrb, config, ctx);
  mrb_load_string_cxt(mrb, response, ctx);
  mrb_load_string_cxt(mrb, run, ctx);

  mrbc_context_free(mrb, ctx);
  mrb_close(mrb);
  return 0;
}
