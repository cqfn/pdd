# Copyright (c) 2014-2017 Yegor Bugayenko
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
require 'tmpdir'
require_relative '../lib/pdd'
require_relative '../lib/pdd/sources'

# Source test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2017 Yegor Bugayenko
# License:: MIT
class TestSource < Minitest::Test
  def test_parsing
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #44 привет,
        *  how are you\t\r\tdoing?
        * -something else
        Something else
        ~~ \x40todo #ABC-3 this is another puzzle
        ~~  and it also has to work
        "
      )
      list = PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      assert_equal 2, list.size
      puzzle = list.first
      assert_equal '2-3', puzzle.props[:lines]
      assert_equal 'привет, how are you doing?', puzzle.props[:body]
      assert_equal '44', puzzle.props[:ticket]
      assert puzzle.props[:author].nil?
      assert puzzle.props[:email].nil?
      assert puzzle.props[:time].nil?
    end
  end

  def test_failing_on_invalid_puzzle
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #44 this is an incorrectly formatted puzzle,
        * with a second line without a leading space
        "
      )
      error = assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      end
      assert !error.message.index('Space expected').nil?
    end
  end

  def test_failing_on_incomplete_puzzle
    Dir.mktmpdir 't5' do |dir|
      file = File.join(dir, 'ff.txt')
      File.write(
        file,
        "
        * \x40todo this puzzle misses ticket name/number
        "
      )
      error = assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'ff')).puzzles
      end
      assert !error.to_s.index("\x40todo is not followed by").nil?
    end
  end

  def test_failing_on_broken_unicode
    skip if Gem.win_platform?
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'xx.txt')
      File.write(file, ' * \x40todo #44 this is a broken unicode: ' + 0x92.chr)
      assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'xx')).puzzles
      end
    end
  end

  def test_failing_on_invalid_puzzle_without_hash_sign
    skip('doesnt work now')
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        '
        * \x40todo 44 this puzzle is not formatted correctly
        '
      )
      error = assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      end
      assert !error.message.index('Incorrect format').nil?
    end
  end

  def test_failing_on_puzzle_without_leading_space
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'hey.txt')
      File.write(
        file,
        "
        *\x40todo #999 this is an incorrectly formatted puzzle!
        "
      )
      error = assert_raises PDD::Error do
        PDD::VerboseSource.new(file, PDD::Source.new(file, 'x')).puzzles
      end
      assert !error.message.index("\x40todo must have a leading space").nil?
    end
  end

  def test_reads_git_author
    skip if Gem.win_platform?
    Dir.mktmpdir 'test' do |dir|
      raise unless system("
        set -e
        cd '#{dir}'
        git init --quiet .
        git config user.email test@teamed.io
        git config user.name test
        echo '\x40todo #1 this is the puzzle' > a.txt
        git add a.txt
        git commit --quiet -am 'first version'
      ")
      list = PDD::Source.new(File.join(dir, 'a.txt'), '').puzzles
      assert_equal 1, list.size
      puzzle = list.first
      assert_equal '1-de87adc8', puzzle.props[:id]
      assert_equal '1-1', puzzle.props[:lines]
      assert_equal 'this is the puzzle', puzzle.props[:body]
      assert_equal 'test', puzzle.props[:author]
      assert_equal 'test@teamed.io', puzzle.props[:email]
      assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, puzzle.props[:time])
    end
  end
end
