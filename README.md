<img src="https://avatars2.githubusercontent.com/u/24456188" width="64px" height="64px"/>

[![EO principles respected here](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org)
[![Managed by Zerocracy](https://www.0crat.com/badge/C3T46CUJJ.svg)](https://www.0crat.com/p/C3T46CUJJ)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/pdd)](http://www.rultor.com/p/yegor256/pdd)
[![We recommend RubyMine](http://img.teamed.io/rubymine-recommend.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/yegor256/pdd.svg)](https://travis-ci.org/yegor256/pdd)
[![Build status](https://ci.appveyor.com/api/projects/status/b59sdhuu0gcku15b?svg=true)](https://ci.appveyor.com/project/yegor256/pdd)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/pdd)](http://www.0pdd.com/p?name=yegor256/pdd)

[![Gem Version](https://badge.fury.io/rb/pdd.svg)](http://badge.fury.io/rb/pdd)
[![Dependency Status](https://gemnasium.com/yegor256/pdd.svg)](https://gemnasium.com/yegor256/pdd)
[![Maintainability](https://api.codeclimate.com/v1/badges/c8e46256fdd8ddc817e5/maintainability)](https://codeclimate.com/github/yegor256/pdd/maintainability)
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

If you use it in combination with [0pdd](http://www.0pdd.com),
after processing this text, the issue titled
"File.java:10-13: This is something to do later in one of ..." will be created.
The specified markers will be included in the issues body
along with some predefined text. If your comment is longer
than 40 characters, it will be truncated in the title.

It starts with `@todo`, followed by a space and a mandatory puzzle **marker**.
Possible formats of puzzle markers (it doesn't matter what the
line starts with and where it is located,
as long as you have that `@todo` right in front
of the mandatory marker):

```
// @todo #224
/* @todo #TEST-13 */
# @todo #55:45min
@todo #67/DES
;; @todo #678:40m/DEV
```

Here `DES` and `DEV` are the roles of people who must fix that puzzles;
`45min` and `40m` is the amount of time the puzzle should take;
`224`, `TEST-13`, `55`, `67`, and `678` are the IDs of the tickets these
puzzles are coming from.

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

  * `min-estimate:15` blocks all puzzles that don't have an estimate
  or their estimates are less than 15 minutes.

  * `max-estimate:120` blocks all puzzles with estimates over 120 minutes.

  * `available-roles:DEV,IMP,DES` specifies a list of roles that
  are allowed in puzzles. Puzzles without explicitly specified
  roles will be rejected.

  * `min-words:5` blocks puzzles with descriptions shorter than five words.

  * `max-duplicates:1` blocks more than one duplicate of any puzzle.
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

  * `ticket` is a ticket name puzzle marker starts from, in most
    cases it will be the number of GitHub issue.

  * `estimate` is the amount of minutes the puzzle is supposed to take.

  * `id` is a unique ID of the puzzle. It is calculated by the
    internal algorithm that takes into account only the text of the puzzle.
    Thus, if you move the puzzle from one file to another, the ID won't
    change. Also, changing the location of a puzzle inside a file
    won't change its ID.

  * `lines` is where the puzzle is found, inside the file.

## How to contribute?

Just submit a pull request. Make sure `rake` passes.

This is how you run the tool locally to test how it works:

```bash
$ ./bin/pdd --help
```

## License

(The MIT License)

Copyright (c) 2016-2018 Yegor Bugayenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
