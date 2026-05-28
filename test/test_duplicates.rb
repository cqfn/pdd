# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require_relative '../lib/pdd/rule/duplicates'
require_relative 'test__helper'

# PDD::Rule::MaxDuplicates class test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestMaxDuplicates < Minitest::Test
  def test_max_duplicates
    refute_empty(
      PDD::Rule::MaxDuplicates.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><body>test</body></puzzle>
        <puzzle><body>test</body></puzzle></puzzles>'
        ), 1
      ).errors,
      'why it is empty?'
    )
  end

  def test_max_duplicates_without_errors
    assert_empty(
      PDD::Rule::MaxDuplicates.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><body>hello</body></puzzle></puzzles>'
        ), 1
      ).errors,
      'it has to be empty!'
    )
  end
end
