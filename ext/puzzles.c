#include "ruby/ruby.h"
#include "ruby/encoding.h"
#include "library.h"
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    VALUE *array;
    size_t used;
    size_t size;
} DynamicArrayObject;

void initArray(DynamicArrayObject *a, size_t initialSize)
{
    a->array = malloc(initialSize * sizeof(int));
    a->used = 0;
    a->size = initialSize;
}

void insertArray(DynamicArrayObject *a, int element)
{
    // a->used is the number of used entries, because a->array[a->used++] updates a->used only *after* the array has been accessed.
    // Therefore a->used can go up to a->size
    if (a->used == a->size)
    {
        a->size *= 2;
        a->array = realloc(a->array, a->size * sizeof(int));
    }
    a->array[a->used++] = element;
}

void freeArray(DynamicArrayObject *a)
{
    free(a->array);
    a->array = NULL;
    a->used = a->size = 0;
}

static bool check_basic_rules_extension(VALUE value)
{

    Check_Type(value, T_STRING);

    char *verifiable;
    verifiable = malloc(sizeof(char) * 1000);
    strcpy(verifiable, value);

    regex_t regex;
    int reti;
    char msgbuf[100];

    char regexpArray[] =
        {
            "[^[[:space:]]]@todo",
            "@todo(?![[:space:]]+#)",
            "@todo[[:space:]]+#[[:space:]]",
            "[^[[:space:]]]TODO:?",
            "TODO(?!:?[[:space:]]+#",
            "TODO:?[[:space:]]+#[[:space:]]"};

    for (int i = 0; i < 6; ++i)
    {
        /* Compile regular expressions */
        reti = regcomp(&regex, &regexpArray[i], 0);
        if (reti)
        {
            fprintf(stderr, "Could not compile regex\n");
        }

        /* Execute regular expression */
        reti = regexec(&regex, verifiable, 0, NULL, 0);
        if (!reti)
        {
            puts(" TODO found, but puzzle can't be parsed, \n most probably because #{todo} is not followed by a puzzle marker, \n as this page explains: https://github.com/yegor256/pdd#how-to-format");
            regfree(&regex);
            return (false);
        }
        else if (reti != REG_NOMATCH)
        {
            regerror(reti, &regex, msgbuf, sizeof(msgbuf));
            fprintf(stderr, "Regex match failed: %s\n", msgbuf);
            regfree(&regex);
            return (false);
        }

        /* Free compiled regular expression if you want to use the regex_t again */
        regfree(&regex);
        return (true);
    }
}

static bool check_general_puzzle_rule(VALUE obj)
{
    Check_Type(value, T_STRING);

    regex_t regex;
    int reti;
    char msgbuf[100];

    /* Compile regular expression */
    reti = regcomp(&regex, "(.*(?:^|[[:space:]]))#{pfx}[[:space:]]+#([[a-zA-Z0-9_]\-\.:/]+)[[:space:]]+(.+)", 0);
    if (reti)
    {
        fprintf(stderr, "Could not compile regex\n");
        exit(1);
    }

    /* Execute regular expression */
    reti = regexec(&regex, line, 0, NULL, 0);

    if (!reti)
    {
        \\match return (true);
    }
    regfree(&regex);
    return (false);
}

static VALUE puzzle_collector(VALUE self, VALUE file, VALUE klass)
{
    //TODO: 1 implement parsing lines to Init_puzzles
    //TODO: 2 add Rescue
    fprintf(stderr, "Reading puzzles from path...");
    DynamicArrayObject puzzles;
    DynamicArrayObject lines;
    initArray(&puzzles, 0);
    FILE *myfile = fopen(file, "r");
    if (myfile == NULL)
    {
        printf("Cannot open file.\n");
        return 1;
    }
    else
    {
        //Check for number of line
        int count = 0;
        do
        {
            if (fgetc(myfile) == '\n')
                count++;
        } while (fgetc(myfile) != EOF);

        rewind(myfile);

        for (int i = 0; i < count; i++)
        {
            char line[100];
            fscanf(myfile, "%[^\n]%*c", line);
            if (check_basic_rules_extension(line))
            {
                //                const char *TODO_presets[2];
                //                TODO_presets[0] = "@todo";
                //                TODO_presets[1] = "TODO:";
                char *ret;
                ret = strcasestr(line, "@todo");
                if (ret)
                {
                    //printf("found substring at address %p\n", ret);
                    if (check_general_puzzle_rule(line))
                    {
                        //TODO: insert intitialization from ruby call func
                        result = rb_funcall(klass, puzzle("=="), 3, Qnil);
                        insertArray(&puzzles, result);
                    }
                }
                else
                {
                    ret = strcasestr(line, "TODO:");
                    if (ret)
                    {
                        //printf("found substring at address %p\n", ret);
                        if (check_general_puzzle_rule(line))
                        {
                            //TODO: insert intitialization from ruby call func
                            result = rb_funcall(obj, rb_intern("=="), 1, Qnil);
                            insertArray(&puzzles, result);
                        }
                    }
                }
            }
        }
    }
    return puzzles;
}

void Init_puzzles(void)
{
    VALUE CFromRubyExample = rb_define_module("PuzzlesCollectorExtension");
    VALUE NativeHelpers = rb_define_class_under(PuzzlesCollectorExtension, "NativeHelpers", rb_cObject);

    rb_define_singleton_method(NativeHelpers, "basic_check_rules_extension", string, 1);
    // rb_define_singleton_method(NativeHelpers, "puzzle_collector", number, 1);
}