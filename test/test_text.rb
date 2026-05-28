# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require_relative '../lib/pdd/rule/text'
require_relative 'test__helper'

# PDD::Rule::Text module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestText < Minitest::Test
  def test_min_words
    assert_equal(
      1,
      PDD::Rule::Text::MinWords.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><body>short text</body></puzzle>
        <puzzle><body>body with four words</body></puzzle></puzzles>'
        ), 4
      ).errors.size
    )
  end
end
