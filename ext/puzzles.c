#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"
#include <regex.h>

static VALUE check_rules_extension(VALUE self, VALUE value){
    Check_Type(value, T_STRING);

    regex_t regex;
    int reti;
    char msgbuf[100];

    /* Compile regular expressions */

    // original regexp /[^\s]\x40todo/
    reti = regcomp(&regex, "[^[[:blank:]]]\x40todo", 0);
    // original regexp /\x40todo(?!\s+#)/
    reti1 = regcomp(&regex, "\x40todo(?![[:blank:]]+#)", 0);
    // original regexp /\x40todo\s+#\s/
    reti2 = regcomp(&regex, "\x40todo[[:blank:]]+#[[:blank:]]", 0);
    // original regexp /[^\s]TODO:?/
    reti3 = regcomp(&regex, "[^[[:blank:]]]TODO:?", 0);
    // original regexp /TODO(?!:?\s+#)/
    reti4 = regcomp(&regex, "[^[[:blank:]]]TODO:?", 0);
    // original regexp /TODO:?\s+#\s/
    reti5 = regcomp(&regex, "TODO:?[[:blank:]]+#[[:blank:]]", 0);
    if( reti ){ fprintf(stderr, "Could not compile regex\n"); exit(1); }

    /* Execute regular expression */
    reti = regexec(&regex, "abc", 0, NULL, 0);
    if( !reti ){
       puts("Match");
    }
    else if( reti == REG_NOMATCH ){
       puts("No match");
    }
    else{
       regerror(reti, &regex, msgbuf, sizeof(msgbuf));
       fprintf(stderr, "Regex match failed: %s\n", msgbuf);
       exit(1);
    }

    /* Free compiled regular expression if you want to use the regex_t again */
    regfree(&regex);

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