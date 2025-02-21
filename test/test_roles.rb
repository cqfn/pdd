# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'nokogiri'
require_relative '../lib/pdd/rule/roles'

# PDD::Rule::Role module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2025 Yegor Bugayenko
# License:: MIT
class TestRoles < Minitest::Test
  def test_incorrect_role
    rule = PDD::Rule::Roles::Available.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><role>D</role></puzzle></puzzles>'
      ), 'A,B,C'
    )
    assert !rule.errors.empty?, 'why it is empty?'
  end

  def test_correct_role
    rule = PDD::Rule::Roles::Available.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle><role>F</role></puzzle></puzzles>'
      ), 'F,E,G'
    )
    assert rule.errors.empty?, 'why it is not empty?'
  end

  def test_empty_role
    rule = PDD::Rule::Roles::Available.new(
      Nokogiri::XML::Document.parse(
        '<puzzles><puzzle></puzzle></puzzles>'
      ), 'T,R,L'
    )
    assert !rule.errors.empty?, 'why it is empty?'
  end
end
