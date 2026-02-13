# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require 'tmpdir'
require 'slop'
require_relative 'test__helper'
require_relative '../lib/pdd'

# PDD main module test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2014-2026 Yegor Bugayenko
# License:: MIT
class TestPDD < Minitest::Test
  def test_basic
    Dir.mktmpdir 'test' do |dir|
      opts = opts(['-q', '-s', dir, '-e', '**/*.png', '-r', 'max-estimate:15'])
      File.write(File.join(dir, 'a.txt'), "\x40todo #55 hello!")
      matches(
        Nokogiri::XML(PDD::Base.new(opts).xml),
        [
          '/processing-instruction("xml-stylesheet")[contains(.,".xsl")]',
          '/puzzles/@version',
          '/puzzles/@date',
          '/puzzles[count(puzzle)=1]',
          '/puzzles/puzzle[file="a.txt"]'
        ]
      )
    end
  end

  def test_rules_failure
    Dir.mktmpdir 'test' do |dir|
      opts = opts(['-q', '-s', dir, '-e', '**/*.png', '-r', 'min-estimate:30'])
      File.write(File.join(dir, 'a.txt'), "\x40todo #90 hello!")
      assert_raises PDD::Error do
        PDD::Base.new(opts).xml
      end
    end
  end

  def test_git_repo
    Dir.mktmpdir 'test' do |dir|
      opts = opts(['-q', '-s', dir])
      raise unless system("
        cd '#{dir}'
        git init --quiet .
        git config user.email test@teamed.io
        git config user.name 'Mr. Tester'
        mkdir 'a long dir name'
        cd 'a long dir name'
        mkdir 'a kid'
        cd 'a kid'
        echo '\x40todo #1 this is some puzzle' > '.это файл.txt'
        cd ../..
        git add -f .
        git commit --no-verify --quiet -am 'first version'
      ")

      matches(
        Nokogiri::XML(PDD::Base.new(opts).xml),
        [
          '/puzzles[count(puzzle)=1]',
          '/puzzles/puzzle[id]',
          '/puzzles/puzzle[file="a long dir name/a kid/.это файл.txt"]',
          '/puzzles/puzzle[author="Mr. Tester"]',
          '/puzzles/puzzle[email="test@teamed.io"]',
          '/puzzles/puzzle[time]'
        ]
      )
    end
  end

  private

  def opts(args)
    Slop.parse args do |o|
      o.bool '-v', '--verbose'
      o.bool '-q', '--quiet'
      o.bool '--skip-errors'
      o.string '-s', '--source'
      o.array '-e', '--exclude'
      o.array '-r', '--rule'
    end
  end

  def matches(xml, xpaths)
    xpaths.each do |xpath|
      raise "doesn't match '#{xpath}': #{xml}" unless xml.xpath(xpath).size == 1
    end
  end
end
