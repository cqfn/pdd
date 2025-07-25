# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/pdd'
require_relative '../lib/pdd/sources'
require_relative 'test__helper'

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
      refute_nil error.message.index(error_msg)
    end
  end

  def check_missing_puzzle(text)
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(file, text)
      begin
        stub_source_find_github_user(file, 'hey') do |source|
          list = source.puzzles
          assert_equal 0, list.size
        end
      rescue PDD::Error => e
        assert_nil e, "Error is raised #{e.message}"
      end
    end
  end

  def test_todo_parsing
    check_valid_puzzle(
      "
      // @todo #45 task description
      ",
      '2-2',
      'task description',
      '45'
    )
  end

  def test_todo_parsing_multi_line
    check_valid_puzzle(
      "
      // @todo #45 task description
      //  second line
      ",
      '2-3',
      'task description second line',
      '45'
    )
  end

  def test_todo_utf8_encoded_body
    check_valid_puzzle(
      "
      // TODO #45 Привет, мир, мне кофе
      //  вторая линия
      ",
      '2-3',
      'Привет, мир, мне кофе вторая линия',
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

  def test_todo_backslash_escape
    check_valid_puzzle(
      "
      // TODO #45 task description with \\
      ",
      '2-2',
      'task description with \\',
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

  def test_todo_colon_parsing_multi_line_with_empty_line
    check_valid_puzzle(
      "
      // TODO: #45 task description
      //
      //  second line after empty line is not a puzzle text
      ",
      '2-2',
      'task description',
      '45'
    )
  end

  def test_todo_colon_parsing_multi_line_with_empty_line_and_space
    check_valid_puzzle(
      '
      // TODO: #46 task description
      // \
      //  second line after empty line is a part of the puzzle in case of backslash exists
      ',
      '2-4',
      'task description second line after empty line is a part ' \
      'of the puzzle in case of backslash exists',
      '46'
    )
  end

  def test_todo_colon_parsing_double_puzzle_with_empty_line
    check_valid_puzzle(
      '
      // TODO: #46 task description for first
      // \
      // TODO: #47 task description
      ',
      '2-2',
      'task description for first',
      '46',
      2
    )
  end

  def test_todo_parsing_puzzle_javadoc_with_empty_line
    check_valid_puzzle(
      '
      /**
       * TODO: #46 task description
       * \
       */
       * some text
      ',
      '3-3',
      'task description',
      '46'
    )
  end

  def test_todo_parsing_puzzle_last_empty_line
    check_valid_puzzle(
      '
      /**
       * TODO: #47 task description
       * \
',
      '3-3',
      'task description',
      '47'
    )
  end

  def test_todo_colon_parsing_multi_line_random_prefix
    check_valid_puzzle(
      '
    ~~
    ~~ @todo #44 First
    ~~  and
    ~~ second
      ',
      '3-4',
      'First and',
      '44'
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

  def test_todo_not_puzzle
    check_missing_puzzle(
      "
      TODOS_DIR=$PWD
      "
    )
  end
end
