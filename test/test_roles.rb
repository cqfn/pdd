# Copyright (c) 2014-2021 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'nokogiri'
require_relative '../lib/pdd/rule/roles'

# PDD::Rule::Role module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2021 Yegor Bugayenko
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
