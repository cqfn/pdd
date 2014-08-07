[![Build Status](http://img.teamed.io/btn/dark-125x25.svg)](http://www.teamed.io)

[![Build Status](https://travis-ci.org/teamed/pdd.svg)](https://travis-ci.org/teamed/pdd)
[![Gem Version](https://badge.fury.io/rb/pdd.svg)](http://badge.fury.io/rb/pdd)
[![Dependency Status](https://gemnasium.com/teamed/pdd.svg)](https://gemnasium.com/teamed/pdd)
[![Code Climate](http://img.shields.io/codeclimate/github/teamed/pdd.svg)](https://codeclimate.com/github/teamed/pdd)
[![Coverage Status](https://img.shields.io/coveralls/teamed/pdd.svg)](https://coveralls.io/r/teamed/pdd)

Install it first:

```bash
gem install pdd
```

Run it locally:

```bash
pdd
```

Every puzzle has to be formatted like this:

```java
/**
 * @todo #234:15m/DEV This is something to do later
 *  in one of the next releases
 */
```

It starts with `@todo`, followed by a space and a puzzle marker.
Possible formats of puzzle markers:

```
#224
#TEST-13
#55:45min
#67/DES
```

Read this article about
[Puzzle Drive Development](http://www.xdsd.org/2009/03/04/pdd.html).
