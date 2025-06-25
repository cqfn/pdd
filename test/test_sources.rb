# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'
require_relative '../test/test__helper'
require_relative '../lib/pdd/sources'

# Sources test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2025 Yegor Bugayenko
# License:: MIT
class TestSources < Minitest::Test
  def test_iterator
    in_temp(['a.txt', 'b/c.txt']) do |dir|
      list = PDD::Sources.new(dir).fetch
      assert_equal 2, list.size
    end
  end

  def test_ignores_binary_files
    in_temp([]) do |dir|
      [
        'README.md',
        '.git/index',
        'test_assets/elegant-objects.png',
        'test_assets/aladdin.jpg',
        'test_assets/article.pdf',
        'test_assets/cambria.woff',
        'test_assets/favicon.ico'
      ].each { |f| FileUtils.cp(File.join(Dir.pwd, f), dir) }
      list = PDD::Sources.new(dir).fetch
      assert_equal 1, list.size
    end
  end

  def test_detects_all_text_files
    in_temp([]) do |dir|
      exts = %w[(xsl java rb cpp apt js xml c go h txt)]
      exts.each do |ext|
        File.write(File.join(dir, "test.#{ext}"), 'text')
      end
      list = PDD::Sources.new(dir).fetch
      assert_equal(
        exts.size, list.size,
        "Files found: #{list}"
      )
    end
  end

  def test_detects_xml_file
    in_temp(['a.xml']) do |dir|
      File.write(File.join(dir, 'a.xml'), '<?xml version="1.0"?><hello/>')
      list = PDD::Sources.new(dir).fetch
      assert_equal 1, list.size
    end
  end

  def test_detects_js_file
    in_temp(['a.js']) do |dir|
      File.write(File.join(dir, 'a.js'), "#!/usr/bin/env node\nconsole.log('Hi!');")
      list = PDD::Sources.new(dir).fetch
      assert_equal 1, list.size
    end
  end

  def test_excludes_by_pattern
    in_temp(['a/first.txt', 'b/c/d/second.txt']) do |dir|
      list = PDD::Sources.new(dir).exclude('b/c/d/second.txt').fetch
      assert_equal 1, list.size
    end
  end

  def test_excludes_recursively
    in_temp(['a/first.txt', 'b/c/second.txt', 'b/c/d/third.txt']) do |dir|
      list = PDD::Sources.new(dir).exclude('**/*').fetch
      assert_equal 0, list.size
    end
  end

  def test_includes_by_pattern
    in_temp(['a/first.txt', 'b/c/d/second.txt']) do |dir|
      list = PDD::Sources.new(dir).include('b/c/d/second.txt').fetch
      assert_equal 2, list.size
    end
  end

  def test_includes_recursively
    in_temp(['a/first.txt', 'b/c/second.txt', 'b/c/d/third.txt']) do |dir|
      sources = PDD::Sources.new(dir).exclude('b/c/**')
      sources.include('b/c/d/third.txt')
      list = sources.fetch
      assert_equal 2, list.size
    end
  end

  def test_fails_with_verbose_output
    in_temp do |dir|
      File.write(File.join(dir, 'z1.txt'), "\x40todobroken\n")
      error = assert_raises PDD::Error do
        PDD::Sources.new(dir).fetch[0].puzzles
      end
      assert error.message.start_with?('z1.txt; '), "here: #{error.message}"
    end
  end

  private

  def in_temp(files = [])
    Dir.mktmpdir 'x' do |dir|
      files.each do |path|
        file = File.join(dir, path)
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, 'some test content')
      end
      yield dir
    end
  end
end
