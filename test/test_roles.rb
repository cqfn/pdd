# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require_relative '../lib/pdd/rule/roles'
require_relative 'test__helper'

# PDD::Rule::Role module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestRoles < Minitest::Test
  def test_incorrect_role
    refute_empty(
      PDD::Rule::Roles::Available.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><role>D</role></puzzle></puzzles>'
        ), 'A,B,C'
      ).errors,
      'why it is empty?'
    )
  end

  def test_correct_role
    assert_empty(
      PDD::Rule::Roles::Available.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle><role>F</role></puzzle></puzzles>'
        ), 'F,E,G'
      ).errors,
      'why it is not empty?'
    )
  end

  def test_empty_role
    refute_empty(
      PDD::Rule::Roles::Available.new(
        Nokogiri::XML::Document.parse(
          '<puzzles><puzzle></puzzle></puzzles>'
        ), 'T,R,L'
      ).errors,
      'why it is empty?'
    )
  end
end
