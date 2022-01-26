#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"


static VALUE check_rules_extension(VALUE self, VALUE value){
    Check_Type(value, T_STRING);
    //TODO: implement parsing current line to check if suitable
    return T_NIL;
}


void Init_puzzles(void) {
  VALUE CFromRubyExample = rb_define_module("CFromRubyExample");
  VALUE NativeHelpers = rb_define_class_under(CFromRubyExample, "NativeHelpers", rb_cObject);

  rb_define_singleton_method(NativeHelpers, "string", string, 1);
  rb_define_singleton_method(NativeHelpers, "number", number, 1);
  rb_define_singleton_method(NativeHelpers, "boolean", boolean, 1);
}