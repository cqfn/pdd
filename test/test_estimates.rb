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
require_relative '../lib/pdd/rule/estimates'

# PDD::Rule::Estimate module tests.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2021 Yegor Bugayenko
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
