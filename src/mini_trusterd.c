#include <stdio.h>
#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/variable.h"

const char config[] = "                                       \n\
                       s = HTTP2::Server.new({                \n\
                           # instance variable from C         \n\
                           :port => @port,                    \n\
                           :document_root => './',            \n\
                           :server_name => 'mini_trusterd',   \n\
                           :tls => false,                     \n\
                           :callback => true,                 \n\
                           :worker => 'auto',                 \n\
                       })                                     \n\
";

const char response[] = "                                     \n\
                       s.set_map_to_storage_cb {               \n\
                         if s.request.uri =~ /hello/          \n\
                           s.set_content_cb {                 \n\
                             s.rputs 'hello mini-trusterd '   \n\
                             s.echo @echo_content             \n\
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

  // 8080 into instance variable "@port" of main on same ctx
  mrb_iv_set(mrb, mrb_top_self(mrb), mrb_intern_lit(mrb, "@port"), mrb_fixnum_value(8080));
  mrb_iv_set(mrb, mrb_top_self(mrb), mrb_intern_lit(mrb, "@echo_content"), mrb_str_new_lit(mrb, "world from cb."));
  mrb_load_string_cxt(mrb, config, ctx);
  mrb_load_string_cxt(mrb, response, ctx);
  mrb_load_string_cxt(mrb, run, ctx);

  mrbc_context_free(mrb, ctx);
  mrb_close(mrb);
  return 0;
}
