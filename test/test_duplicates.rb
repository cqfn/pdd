# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'nokogiri'
require_relative '../lib/pdd/rule/duplicates'

# PDD::Rule::MaxDuplicates class test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestMaxDuplicates < Minitest::Test
  def test_max_duplicates
    rule = PDD::Rule::MaxDuplicates.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><body>test</body></puzzle>
        <puzzle><body>test</body></puzzle></puzzles>'
      ), 1
    )
    refute_empty rule.errors, 'why it is empty?'
  end

  def test_max_duplicates_without_errors
    rule = PDD::Rule::MaxDuplicates.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><body>hello</body></puzzle></puzzles>'
      ), 1
    )
    assert_empty rule.errors, 'it has to be empty!'
  end
end
