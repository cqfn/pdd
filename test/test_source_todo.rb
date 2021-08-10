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
require 'tmpdir'
require_relative '../lib/pdd'
require_relative '../lib/pdd/sources'

class TestSourceTodo < Minitest::Test
  def check_valid_puzzle(text, lines, body, ticket, count = 1)
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(file, text)
      stub_source_find_github_user(file, 'hey') do |source|
        list = source.puzzles
        assert_equal count, list.size
        puzzle = list.first
        assert_equal lines, puzzle.props[:lines]
        assert_equal body, puzzle.props[:body]
        assert_equal ticket, puzzle.props[:ticket]
      end
    end
  end

  def check_invalid_puzzle(text, error_msg)
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(file, text)
      error = assert_raises PDD::Error do
        stub_source_find_github_user(file, 'hey', &:puzzles)
      end
      assert !error.message.index(error_msg).nil?
    end
  end

  def test_todo_parsing
    check_valid_puzzle(
      "
      // TODO #45 task description
      ",
      '2-2',
      'task description',
      '45'
    )
  end

  def test_todo_parsing_multi_line
    check_valid_puzzle(
      "
      // TODO #45 task description
      //  second line
      ",
      '2-3',
      'task description second line',
      '45'
    )
  end

  def test_todo_colon_parsing
    check_valid_puzzle(
      "
      // TODO: #45 task description
      ",
      '2-2',
      'task description',
      '45'
    )
  end

  def test_multiple_todo_colon
    check_valid_puzzle(
      "
      // TODO: #45 task description
      // TODO: #46 another task description
      ",
      '2-2',
      'task description',
      '45',
      2
    )
  end

  def test_todo_colon_parsing_multi_line
    check_valid_puzzle(
      "
      // TODO: #45 task description
      //  second line
      ",
      '2-3',
      'task description second line',
      '45'
    )
  end

  def test_todo_failing_no_space_on_second_line
    check_invalid_puzzle(
      "
      * TODO #45 this puzzle
      * has not space on second line",
      'Space expected'
    )
  end

  def test_todo_colon_failing_no_space_on_second_line
    check_invalid_puzzle(
      "
      * TODO: #45 this puzzle
      * has not space on second line",
      'Space expected'
    )
  end

  def test_todo_failing_no_ticket
    check_invalid_puzzle(
      "
      * TODO this puzzle misses ticket name/number
      ",
      'TODO is not followed by'
    )
  end

  def test_todo_colon_failing_no_ticket
    check_invalid_puzzle(
      "
      * TODO: this puzzle misses ticket name/number
      ",
      'TODO is not followed by'
    )
  end

  def test_todo_failing_space_after_hash
    check_invalid_puzzle(
      "
      * TODO # 45 this puzzle has space after hash
      ",
      'TODO found, but there is an unexpected space after the hash sign'
    )
  end

  def test_todo_colon_failing_space_after_hash
    check_invalid_puzzle(
      "
      * TODO: # 45 this puzzle has space after hash
      ",
      'TODO found, but there is an unexpected space after the hash sign'
    )
  end

  def test_todo_failing_no_space_before
    check_invalid_puzzle(
      "
      *TODO #45 this puzzle has no space before todo
      ",
      'TODO must have a leading space'
    )
  end

  def test_todo_colon_failing_no_space_before
    check_invalid_puzzle(
      "
      *TODO: #45 this puzzle has no space before todo
      ",
      'TODO must have a leading space'
    )
  end
end
