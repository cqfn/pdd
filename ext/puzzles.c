#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"
#include <regex.h>

static void check_rules_extension(VALUE self, VALUE value){
    regex_t regex;
    int reti;
    char msgbuf[100];
    Check_Type(value, T_STRING);

    char regexpArray[] = {
        "[^[[:space:]]]\x40todo",
        "\x40todo(?![[:space:]]+#)",
        "\x40todo[[:space:]]+#[[:space:]]",
        "[^[[:space:]]]TODO:?",
        "TODO(?!:?[[:space:]]+#",
        "TODO:?[[:space:]]+#[[:space:]]"
        };

    for (int i = 0, i < 6; ++i){

        /* Compile regular expressions */
        reti = regcomp(&regex, regexpArray[i], 0);
        if( reti ){ fprintf(stderr, "Could not compile regex\n"); exit(1); }

        /* Execute regular expression */
        reti = regexec(&regex, value, 0, NULL, 0);
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

    }
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