# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative '../utils/glob'
require_relative 'test__helper'

# PDD::Glob test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestGlob < Minitest::Test
  def test_converts_plain_pattern
    assert_equal('foo/.*\\.rb', PDD::Glob.new('foo/*.rb').to_regexp)
  end

  def test_expands_braces
    assert_equal('.*\\.(rb|js)', PDD::Glob.new('**/*.{rb,js}').to_regexp)
  end

  def test_keeps_unmatched_closing_brace
    assert_equal('a}b', PDD::Glob.new('a}b').to_regexp)
  end

  def test_keeps_escaped_char_literal
    assert_equal('a\\*b', PDD::Glob.new('a\\*b').to_regexp)
  end
end
