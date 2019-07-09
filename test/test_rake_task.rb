require 'minitest/autorun'
require 'tmpdir'
require 'rake'
require_relative '../lib/pdd/rake_task'

# Test for RakeTask
class TestRakeTask < Minitest::Test
  def test_base
    error = assert_raises SystemExit do
      PDD::RakeTask.new
    end
    assert_equal('NOT IMPLEMENTED', error.message)
  end
end
