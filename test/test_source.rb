# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/pdd'
require_relative '../lib/pdd/sources'
require_relative 'test__helper'

# Source test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2025 Yegor Bugayenko
# License:: MIT
class TestSource < Minitest::Test
  def test_parsing
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #44 привет,
        *  how are you\t\tdoing?
        * -something else
        Something else
        ~~ \x40todo #ABC-3 this is another puzzle
        ~~  and it also has to work
        "
      )
      stub_source_find_github_user(file, 'hey') do |source|
        list = source.puzzles
        assert_equal 2, list.size
        puzzle = list.first
        assert_equal '2-3', puzzle.props[:lines]
        assert_equal 'привет, how are you doing?',
                     puzzle.props[:body]
        assert_equal '44', puzzle.props[:ticket]
        assert_nil puzzle.props[:author]
        assert_nil puzzle.props[:email]
        assert_nil puzzle.props[:time]
      end
    end
  end

  def test_parsing_leading_spaces
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #56:30min this is a
        *       multi-line
        *     comment!
        "
      )
      stub_source_find_github_user(file, 'hey') do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_equal '2-4', puzzle.props[:lines]
        assert_equal 'this is a multi-line comment!', puzzle.props[:body]
        assert_equal '56', puzzle.props[:ticket]
      end
    end
  end

  def test_no_prefix_multiline_puzzle_block
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        <!--
        \x40todo #01:30min correctly formatted multi-line puzzle, with no
          comment prefix before todo marker
        -->
        "
      )
      stub_source_find_github_user(file, 'hey') do |source|
        PDD.opts = nil
        assert_equal 1, source.puzzles.size
        puzzle = source.puzzles.last
        assert_equal '3-4', puzzle.props[:lines]
        assert_equal 'correctly formatted multi-line puzzle, with no ' \
                     'comment prefix before todo marker', puzzle.props[:body]
        assert_equal '01', puzzle.props[:ticket]
      end
    end
  end

  def test_space_indented_multiline_puzzle_block
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
         # \x40todo #99:30min hello
         #  good bye
         # hello again
        "
      )
      stub_source_find_github_user(file, 'hey') do |source|
        PDD.opts = nil
        assert_equal 1, source.puzzles.size
        puzzle = source.puzzles.last
        assert_equal '2-3', puzzle.props[:lines]
        assert_equal 'hello good bye', puzzle.props[:body]
        assert_equal '99', puzzle.props[:ticket]
      end
    end
  end

  def test_multiple_puzzles_single_comment_block
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        /*
         * \x40todo #1 First one with
         * a few lines
         * \x40todo #1 Second one also
         * with a few lines of text
         */
        "
      )
      stub_source_find_github_user(file, 'hey') do |source|
        PDD.opts = nil
        assert_equal 2, source.puzzles.size
        puzzle = source.puzzles.last
        assert_equal '5-6', puzzle.props[:lines]
        assert_equal 'Second one also with a few lines of text', puzzle.props[:body]
        assert_equal '1', puzzle.props[:ticket]
      end
    end
  end

  def test_succeed_despite_bad_puzzles
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #44 this is a correctly formatted puzzle,
        * with a second line without a leading space
        Another badly formatted puzzle
        * \x40todo this bad puzzle misses ticket name/number
        Something else
        * \x40todo #123 This puzzle is correctly formatted
        "
      )
      PDD.opts = { 'skip-errors' => true }
      stub_source_find_github_user(file, 'hey') do |source|
        list = source.puzzles
        PDD.opts = nil
        assert_equal 2, list.size
        puzzle = list.first
        assert_equal '2-3', puzzle.props[:lines]
        assert_equal 'this is a correctly formatted puzzle, with a second ' \
                     'line without a leading space', puzzle.props[:body]
        assert_equal '44', puzzle.props[:ticket]
      end
    end
  end

  def test_succeed_utf8_encoded_body
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo #44 Привет, мир, мне кофе
        *  вторая линия
        "
      )
      list = PDD::VerboseSource.new(file, PDD::Source.new(file, 'hey')).puzzles
      assert_equal 1, list.size
      puzzle = list.first
      assert_equal '2-3', puzzle.props[:lines]
      assert_equal 'Привет, мир, мне кофе вторая линия', puzzle.props[:body]
      assert_equal '44', puzzle.props[:ticket]
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
        stub_source_find_github_user(file, 'ff', &:puzzles)
      end
      refute_nil error.to_s.index("\x40todo is not followed by")
    end
  end

  def test_failing_on_broken_unicode
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'xx.txt')
      File.write(file, " * \\x40todo #44 this is a broken unicode: #{0x92.chr}")
      assert_raises PDD::Error do
        stub_source_find_github_user(file, 'xx', &:puzzles)
      end
    end
  end

  def test_failing_on_invalid_puzzle_without_hash_sign
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        "
        * \x40todo 44 this puzzle is not formatted correctly
        "
      )
      error = assert_raises PDD::Error do
        stub_source_find_github_user(file, 'hey', &:puzzles)
      end
      refute_nil error.message.index('is not followed by a puzzle marker')
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
        stub_source_find_github_user(file, 'x', &:puzzles)
      end
      refute_nil error.message.index("\x40todo must have a leading space")
    end
  end

  def test_failing_on_puzzle_with_space_after_dash
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'hey-you.txt')
      File.write(
        file,
        "
        * \x40todo # 123 This puzzle has an unnecessary space before the dash
        "
      )
      error = assert_raises PDD::Error do
        stub_source_find_github_user(file, 'x', &:puzzles)
      end
      refute_nil error.message.index('an unexpected space')
    end
  end

  def test_reads_git_author
    Dir.mktmpdir 'test' do |dir|
      raise unless system("
        set -e
        cd '#{dir}'
        git init --quiet .
        git config user.email test@teamed.io
        git config user.name test_unknown
        echo '\x40todo #1 this is the puzzle' > a.txt
        git add a.txt
        git commit --no-verify --quiet -am 'first version'
      ")

      stub_source_find_github_user(File.join(dir, 'a.txt')) do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_equal '1-de87adc8', puzzle.props[:id]
        assert_equal '1-1', puzzle.props[:lines]
        assert_equal 'this is the puzzle', puzzle.props[:body]
        assert_equal 'test_unknown', puzzle.props[:author]
        assert_equal 'test@teamed.io', puzzle.props[:email]
        assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/,
                     puzzle.props[:time])
      end
    end
  end

  def test_skips_invalid_git_mail
    Dir.mktmpdir 'test' do |dir|
      raise unless system("
        set -e
        cd '#{dir}'
        git init --quiet .
        git config user.email invalid-email
        git config user.name test
        echo '\x40todo #1 this is the puzzle' > a.txt
        git add a.txt
        git commit --no-verify --quiet -am 'first version'
      ")

      stub_source_find_github_user(File.join(dir, 'a.txt')) do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_equal '1-de87adc8', puzzle.props[:id]
        assert_equal '1-1', puzzle.props[:lines]
        assert_equal 'this is the puzzle', puzzle.props[:body]
        assert_equal 'test', puzzle.props[:author]
        assert_nil puzzle.props[:email]
        assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/,
                     puzzle.props[:time])
      end
    end
  end

  def test_uses_github_login
    Dir.mktmpdir 'test' do |dir|
      raise unless system("
        cd '#{dir}'
        git init --quiet .
        git config user.email yegor256@gmail.com
        git config user.name test
        echo '\x40todo #1 this is the puzzle' > a.txt
        git add a.txt
        git commit --no-verify --quiet -am 'first version'
      ")

      stub_source_find_github_user(File.join(dir, 'a.txt')) do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_equal '@yegor256', puzzle.props[:author]
      end
    end
  end

  def test_skips_uncommitted_changes
    Dir.mktmpdir 'test' do |dir|
      raise unless system("
        cd '#{dir}'
        git init --quiet .
        git config user.email yegor256@gmail.com
        git config user.name test
        echo 'hi' > a.txt
        git add a.txt
        git commit --no-verify --quiet -am 'first version'
        echo '\x40todo #1 this is a puzzle uncommitted' > a.txt
      ")

      stub_source_find_github_user(File.join(dir, 'a.txt')) do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_nil puzzle.props[:email]
        assert_equal 'Not Committed Yet', puzzle.props[:author]
      end
    end
  end

  def test_skips_thymeleaf_close_tag
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(
        file,
        '<!--/* @todo #123 puzzle info */-->'
      )
      stub_source_find_github_user(file, 'hey') do |source|
        list = source.puzzles
        assert_equal 1, list.size
        puzzle = list.first
        assert_equal '1-1', puzzle.props[:lines]
        assert_equal 'puzzle info', puzzle.props[:body]
        assert_equal '123', puzzle.props[:ticket]
      end
    end
  end
end
