# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/pdd'
require_relative '../lib/pdd/sources'

# Test many puzzles to make sure their IDs are correct.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestMany < Minitest::Test
  def test_parsing
    Dir['./test_assets/puzzles/**'].each do |p|
      name = File.basename(p)
      list = PDD::Source.new("./test_assets/puzzles/#{name}", 'hey').puzzles
      assert_equal 1, list.size
      puzzle = list.first
      puts "#{name}: \"#{puzzle.props[:body]}\""
      next if name.start_with?('_')
      assert_equal name, puzzle.props[:id]
    end
  end
end
