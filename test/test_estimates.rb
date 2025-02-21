# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'nokogiri'
require_relative '../lib/pdd/rule/estimates'

# PDD::Rule::Estimate module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2025 Yegor Bugayenko
# License:: MIT
class TestEstimates < Minitest::Test
  def test_min
    rule = PDD::Rule::Estimate::Min.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><estimate>15</estimate></puzzle></puzzles>'
      ), 30
    )
    assert !rule.errors.empty?, 'why it is empty?'
  end

  def test_max
    rule = PDD::Rule::Estimate::Max.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><estimate>30</estimate></puzzle></puzzles>'
      ), 15
    )
    assert !rule.errors.empty?, 'why it is empty?'
  end
end
