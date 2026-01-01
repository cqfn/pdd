# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'tmpdir'
require 'rake'
require_relative '../lib/pdd/rake_task'

# Test for RakeTask
class TestRakeTask < Minitest::Test
  def test_basic
    Dir.mktmpdir 'test' do |dir|
      file = File.join(dir, 'a.txt')
      File.write(file, "\x40todo #55 hello!")
      PDD::RakeTask.new(:pdd1) do |task|
        task.quiet = true
      end
      Rake::Task['pdd1'].invoke
    end
  end
end
