#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"
#include <regex.h>

static void check_rules_extension(VALUE self, VALUE value){

    Check_Type(value, T_STRING);

    char* verifiable;
    verifiable = malloc (sizeof(char) * 1000);
    strcpy( verifiable, value);

    regex_t regex;
    int reti;
    char msgbuf[100];

    char regexpArray[] = {
        "[^[[:space:]]]\x40todo",
        "\x40todo(?![[:space:]]+#)",
        "\x40todo[[:space:]]+#[[:space:]]",
        "[^[[:space:]]]TODO:?",
        "TODO(?!:?[[:space:]]+#",
        "TODO:?[[:space:]]+#[[:space:]]"
        };


    for (int i = 0; i < 6; ++i){
        /* Compile regular expressions */
        reti = regcomp(&regex, &regexpArray[i], 0);
        if( reti ){ fprintf(stderr, "Could not compile regex\n"); }

        /* Execute regular expression */
        reti = regexec(&regex, verifiable, 0, NULL, 0);
        if( !reti ){
            puts(" TODO found, but puzzle can't be parsed, \n most probably because #{todo} is not followed by a puzzle marker, \n as this page explains: https://github.com/yegor256/pdd#how-to-format");
        }
        else if( reti != REG_NOMATCH ){
            regerror(reti, &regex, msgbuf, sizeof(msgbuf));
            fprintf(stderr, "Regex match failed: %s\n", msgbuf);
            //exit(1);
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