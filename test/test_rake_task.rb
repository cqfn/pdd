require 'minitest/autorun'
require 'tmpdir'
require 'rake'
require_relative '../lib/pdd/rake_task'

# Test for RakeTask
class TestRakeTask < Minitest::Test
  def test_base
    PDD::RakeTask.new(:pdd1)
    error = assert_raises SystemExit do
      Rake::Task['pdd1'].invoke
    end
    assert_equal('NOT IMPLEMENTED', error.message)
  end
end
