#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"


static VALUE check_rules_extension(VALUE self, VALUE value){
    Check_Type(value, T_STRING);
    //TODO: implement parsing current line to check if suitable
    return T_NIL;
}

static VALUE puzzle_collector(VALUE self, VALUE value){
    //TODO: implement parsing lines to Init_puzzles
    return T_NIL;
}


void Init_puzzles(void) {
  VALUE CFromRubyExample = rb_define_module("PuzzlesCollectorExtension");
  VALUE NativeHelpers = rb_define_class_under(PuzzlesCollectorExtension, "NativeHelpers", rb_cObject);

  rb_define_singleton_method(NativeHelpers, "check_rules_extension", string, 1);
  // rb_define_singleton_method(NativeHelpers, "puzzle_collector", number, 1);
}