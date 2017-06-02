<img src="https://avatars2.githubusercontent.com/u/24456188" width="64px" height="64px"/>

[![Made By Teamed.io](http://img.teamed.io/btn.svg)](http://www.teamed.io)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/pdd)](http://www.rultor.com/p/yegor256/pdd)
[![We recommend RubyMine](http://img.teamed.io/rubymine-recommend.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/yegor256/pdd.svg)](https://travis-ci.org/yegor256/pdd)
[![Build status](https://ci.appveyor.com/api/projects/status/b59sdhuu0gcku15b?svg=true)](https://ci.appveyor.com/project/yegor256/pdd)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/pdd)](http://www.0pdd.com/p?name=yegor256/pdd)
[![Gem Version](https://badge.fury.io/rb/pdd.svg)](http://badge.fury.io/rb/pdd)
[![Dependency Status](https://gemnasium.com/yegor256/pdd.svg)](https://gemnasium.com/yegor256/pdd)
[![Code Climate](http://img.shields.io/codeclimate/github/yegor256/pdd.svg)](https://codeclimate.com/github/yegor256/pdd)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/pdd.svg)](https://codecov.io/github/yegor256/pdd?branch=master)

## What This is for?

Read this article about
[Puzzle Driven Development](http://www.yegor256.com/2009/03/04/pdd.html).
Check also patent application [US 12/840,306](http://www.google.com/patents/US20120023476)

Also, check [0pdd.com](http://www.0pdd.com): a hosted service,
where this command line tool works for you. Read this first:
[PDD in Action](http://www.yegor256.com/2017/04/05/pdd-in-action.html).

## How to Install?

Install it first:

```bash
$ gem install pdd
```

## How to Run?

Run it locally and read its output:

```bash
$ pdd --help
```

You can exclude certain files from the search, for example:

```bash
pdd --exclude=src/**/*.java --exclude=target/**/*
pdd --exclude=src/**/*.java # exclude .java files in src/
pdd --exclude=src/**/* # exclude all files in src/
```

## How to Format?

Every puzzle has to be formatted like this (pay attention
to the leading space in every consecutive line):

```java
/**
 * @todo #234:15m/DEV This is something to do later
 *  in one of the next releases. I can't figure out
 *  how to implement it now, that's why the puzzle.
 */
void sendEmail() {
  throw new UnsupportedOperationException();
}
```

It starts with `@todo`, followed by a space and a puzzle marker.
Possible formats of puzzle markers:

```
#224
#TEST-13
#55:45min
#67/DES
#678:40m/DEV
```

## How to Configure Rules?

You can specify post-parsing rules for your puzzles, in command line,
for example:

```
$ pdd --rule=min-estimate:60 --rule=max-estimate:120
```

These two parameters will add two post-parsing rules `min-estimate`
and `max-estimate` with parameters. Each rule may have an optional
parameter specified after a colon.

Here is a list of rules available now:

  * `min-estimate:15` blocks all puzzles that don't have an estimate
  or their estimates are less than 15 minutes.

  * `max-estimate:120` blocks all puzzles with estimates over 120 minutes.

  * `available-roles:DEV,IMP,DES` specifies a list of roles that
  are allowed in puzzles. Puzzles without explicitly specified
  roles will be rejected.

  * `min-words:5` blocks puzzles with descriptions shorter than five words.

  * `max-duplicates:1` blocks more than one duplicate of any puzzle
  (this rule is used by default).

You can put all command line options into `.pdd` file. The options from the
file will be used first. Command line options may be added on top of them.
See, how it is done in [yegor256/0pdd](https://github.com/yegor256/0pdd/blob/master/.pdd).
