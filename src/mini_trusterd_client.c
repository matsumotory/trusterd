#include <stdio.h>
#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/variable.h"

const char request[] = "HTTP2::Client.get @url";

int main(void)
{
  mrb_value response;
  mrb_state *mrb = mrb_open();
  mrbc_context *ctx = mrbc_context_new(mrb);

  // URL into instance variable "@url" of main on same ctx
  mrb_iv_set(mrb, mrb_top_self(mrb), mrb_intern_lit(mrb, "@url"), mrb_str_new_lit(mrb, "https://127.0.0.1:8080/index.html"));
  response = mrb_load_string_cxt(mrb, request, ctx);
  mrb_funcall(mrb, mrb_top_self(mrb), "pp", 1, response);

  mrbc_context_free(mrb, ctx);
  mrb_close(mrb);
  return 0;
}
