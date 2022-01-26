#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"

static VALUE string(VALUE self, VALUE value) {
  Check_Type(value, T_STRING);

  char* pointer_in = RSTRING_PTR(value);
  char* pointer_out = string_from_library(pointer_in);
  return rb_str_new2(pointer_out);
}

static VALUE number(VALUE self, VALUE value) {
  Check_Type(value, T_FIXNUM);

  int number_in = NUM2INT(value);
  int number_out = number_from_library(number_in);
  return INT2NUM(number_out);
}

static VALUE boolean(VALUE self, VALUE value) {
  int boolean_in = RTEST(value);
  int boolean_out = boolean_from_library(boolean_in);
  if (boolean_out == 1) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}

void Init_puzzles(void) {
  VALUE CFromRubyExample = rb_define_module("CFromRubyExample");
  VALUE NativeHelpers = rb_define_class_under(CFromRubyExample, "NativeHelpers", rb_cObject);

  rb_define_singleton_method(NativeHelpers, "string", string, 1);
  rb_define_singleton_method(NativeHelpers, "number", number, 1);
  rb_define_singleton_method(NativeHelpers, "boolean", boolean, 1);
}