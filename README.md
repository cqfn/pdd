<img src="https://avatars2.githubusercontent.com/u/24456188" width="64px" height="64px"/>

[![Donate via Zerocracy](https://www.0crat.com/contrib-badge/C3T46CUJJ.svg)](https://www.0crat.com/contrib/C3T46CUJJ)

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![Managed by Zerocracy](https://www.0crat.com/badge/C3T46CUJJ.svg)](https://www.0crat.com/p/C3T46CUJJ)
[![DevOps By Rultor.com](http://www.rultor.com/b/cqfn/pdd)](http://www.rultor.com/p/cqfn/pdd)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/cqfn/pdd.svg)](https://travis-ci.org/cqfn/pdd)
[![Build status](https://ci.appveyor.com/api/projects/status/b59sdhuu0gcku15b?svg=true)](https://ci.appveyor.com/project/cqfn/pdd)
[![PDD status](http://www.0pdd.com/svg?name=cqfn/pdd)](http://www.0pdd.com/p?name=cqfn/pdd)
[![Test Coverage](https://img.shields.io/codecov/c/github/cqfn/pdd.svg)](https://codecov.io/github/cqfn/pdd?branch=master)
[![Hits-of-Code](https://hitsofcode.com/github/cqfn/pdd)](https://hitsofcode.com/view/github/cqfn/pdd)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/cqfn/pdd/blob/master/LICENSE.txt)

[![Gem Version](https://badge.fury.io/rb/pdd.svg)](http://badge.fury.io/rb/pdd)
[![Maintainability](https://api.codeclimate.com/v1/badges/c8e46256fdd8ddc817e5/maintainability)](https://codeclimate.com/github/cqfn/pdd/maintainability)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/cqfn/pdd/master/frames)

Read this article about
[_Puzzle Driven Development_](http://www.yegor256.com/2009/03/04/pdd.html).
Check also patent application [US 12/840,306](http://www.google.com/patents/US20120023476)

Also, check [0pdd.com](http://www.0pdd.com): a hosted service,
where this command line tool works for you.

Read
[_PDD in Action_](http://www.yegor256.com/2017/04/05/pdd-in-action.html)
and watch [this webinar](https://www.youtube.com/watch?v=nsYGC2aUwfQ).

Install it first:

```bash
$ gem install pdd
```

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
 * @todo #[issue#]<:[time]></[role]> <[description]>
 */
[related code]
```

\[\] - Replace with apropriate data (see text enclosed in brackets)
<> - Omitable (enclosed data can be left out)

Example:

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

If you use it in combination with [0pdd](http://www.0pdd.com),
after processing this text, the issue titled
"File.java:10-13: This is something to do later in one of ..." will be created.
The specified markers will be included in the issues body
along with some predefined text. If your comment is longer
than 40 characters, it will be truncated in the title.

There are 3 supported keywords, one of which must precede the mandatory
puzzle marker. They are `@todo`, `TODO` and `TODO:`.

As an example, it starts with `@todo`, followed by a space and a mandatory
puzzle **marker**. Possible formats of puzzle markers (it doesn't matter what the
line starts with and where it is located,
as long as you have one of the 3 supported keywords right in front
of the mandatory marker):

```
// @todo #224
/* @todo #TEST-13 */
# @todo #55:45min
@todo #67/DES
;; @todo #678:40m/DEV
// TODO: #1:30min
(* TODO #42 *)
```

Here `DES` and `DEV` are the roles of people who must fix that puzzles;
`45min` and `40m` is the amount of time the puzzle should take;
`224`, `TEST-13`, `55`, `67`, `678`, `1`, and `42` are the IDs of the tickets
these puzzles are coming from.

Markers are absolutely necessary for all puzzles, because they allow
us to build a hierarchical dependency tree of all puzzles, like
[this one](http://www.0pdd.com/p?name=yegor256/takes),
for example. Technically, of course, you can abuse the system
and put a dummy `#1` marker everywhere.

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

- `min-estimate:15` blocks all puzzles that don't have an estimate
  or their estimates are less than 15 minutes.

- `max-estimate:120` blocks all puzzles with estimates over 120 minutes.

- `available-roles:DEV,IMP,DES` specifies a list of roles that
  are allowed in puzzles. Puzzles without explicitly specified
  roles will be rejected.

- `min-words:5` blocks puzzles with descriptions shorter than five words.

- `max-duplicates:1` blocks more than one duplicate of any puzzle.
  This rule is used by default and you can't configure it at the moment,
  it must always be set to `1`.

You can put all command line options into `.pdd` file. The options from the
file will be used first. Command line options may be added on top of them.
See, how it is done in [yegor256/0pdd](https://github.com/yegor256/0pdd/blob/master/.pdd).

## How to read XML

The XML produced will look approximately like this (here is a
[real example](http://www.0pdd.com/snapshot?name=yegor256/takes)):

```xml
<puzzles>
  <puzzle>
    <ticket>516</ticket>
    <estimate>15</estimate>
    <role>DEV</role>
    <id>516-ffc97ad1</id>
    <lines>61-63</lines>
    <body>This has to be fixed later...</body>
    <file>src/test/java/org/takes/SomeTest.java</file>
    <author>Yegor Bugayenko</author>
    <email>yegor256@gmail.com</email>
    <time>2018-01-01T21:09:03Z</time>
  </puzzle>
</puzzles>
```

[XSD Schema](http://pdd-xsd.teamed.io/0.19.4.xsd) is here.
The most interesting parts of each puzzle are:

- `ticket` is a ticket name puzzle marker starts from, in most
  cases it will be the number of GitHub issue.

- `estimate` is the amount of minutes the puzzle is supposed to take.

- `id` is a unique ID of the puzzle. It is calculated by the
  internal algorithm that takes into account only the text of the puzzle.
  Thus, if you move the puzzle from one file to another, the ID won't
  change. Also, changing the location of a puzzle inside a file
  won't change its ID.

- `lines` is where the puzzle is found, inside the file.

## How to contribute

Read [these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure your build is green before you contribute
your pull request. You will need to have [Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```
$ bundle install --path .bundle
$ bundle exec rake
```

Next, install and run overcommit to install hooks (required once)
```
$ gem install overcommit -v '=0.58.0'
$ overcommit --install
```

If it's clean and you don't see any error messages, submit your pull request.

This is how you run the tool locally to test how it works:

```bash
$ ./bin/pdd --help
```
