# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'rake'
require 'tmpdir'
require_relative '../lib/pdd/rake_task'
require_relative 'test__helper'

# Test for RakeTask
class TestRakeTask < Minitest::Test
  def test_basic
    Dir.mktmpdir('test') do |dir|
      File.write(File.join(dir, 'a.txt'), "\x40todo #55 hello!")
      PDD::RakeTask.new(:pdd1) do |task|
        task.quiet = true
      end
      Rake::Task['pdd1'].invoke
    end
  end
end
