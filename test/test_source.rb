# encoding: utf-8
#
# Copyright (c) 2014 TechnoPark Corp.
# Copyright (c) 2014 Yegor Bugayenko
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
require 'pdd/sources'
require 'tmpdir'

# Source test.
# Author:: Yegor Bugayenko (yegor@teamed.io)
# Copyright:: Copyright (c) 2014 Yegor Bugayenko
# License:: MIT
class TestSources < Minitest::Test
  def test_parsing
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        '
        * @todo #44 hello,
        *  how are you doing?
        * -something else
        Something else
        ~~ @todo #ABC-3 this is another puzzle
        ~~  and it also has to work
        '
      )
      list = PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      assert_equal 2, list.size
      puzzle = list.first
      assert_equal '2-3', puzzle.props[:lines]
      assert_equal 'hello, how are you doing?', puzzle.props[:body]
      assert_equal '44', puzzle.props[:ticket]
    end
  end

  def test_failing_on_invalid_puzzle
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        '
        * @todo #44 this is an incorrectly formatted puzzle,
        * with a second line without a leading space
        '
      )
      error = assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      end
      assert !error.message.index('Space expected').nil?
    end
  end
end
