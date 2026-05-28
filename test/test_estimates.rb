# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require_relative '../lib/pdd/rule/estimates'
require_relative 'test__helper'

# PDD::Rule::Estimate module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestEstimates < Minitest::Test
  def test_min
    refute_empty(
      PDD::Rule::Estimate::Min.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><estimate>15</estimate></puzzle></puzzles>'
        ), 30
      ).errors,
      'why it is empty?'
    )
  end

  def test_max
    refute_empty(
      PDD::Rule::Estimate::Max.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><estimate>30</estimate></puzzle></puzzles>'
        ), 15
      ).errors,
      'why it is empty?'
    )
  end
end
