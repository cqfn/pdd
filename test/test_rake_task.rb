require 'minitest/autorun'
require 'tmpdir'
require 'rake'
require_relative '../lib/pdd/rake_task'

# Test for RakeTask
class TestRakeTask < Minitest::Test
  def test_basic
    Dir.mktmpdir 'test' do |dir|
      Dir.chdir(dir)
      File.write('a.txt', "\x40todo #55 hello!")
      PDD::RakeTask.new(:pdd1) do |task|
        task.quiet = true
      end
      Rake::Task['pdd1'].invoke
    end
  end
end
