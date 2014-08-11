# encoding: utf-8
#
# Copyright (c) 2014 TechnoPark Corp.
# Copyright (c) 2014 Yegor Bugayenko
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
require 'pdd/sources'
require 'tmpdir'

# Sources test.
# Author:: Yegor Bugayenko (yegor@teamed.io)
# Copyright:: Copyright (c) 2014 Yegor Bugayenko
# License:: MIT
class TestSources < Minitest::Test
  def test_iterator
    Dir.mktmpdir 'test' do |dir|
      File.write(File.join(dir, 'a.txt'), '@todo hello!')
      Dir.mkdir(File.join(dir, 'b'))
      File.write(File.join(dir, 'b/c.txt'), 'hello, again')
      list = PDD::Sources.new(dir).fetch
      assert_equal 2, list.size
    end
  end

  def test_ignores_binary_files
    Dir.mktmpdir 'test' do |dir|
      File.write(File.join(dir, 'c'), 'how are you?')
      File.write(File.join(dir, 'd.png'), '')
      list = PDD::Sources.new(dir).fetch
      assert_equal 1, list.size
    end
  end

  def test_detects_all_text_files
    Dir.mktmpdir 'test' do |dir|
      exts = %w[(xsl java rb cpp apt)]
      exts.each do |ext|
        File.write(File.join(dir, "test.#{ext}"), 'text')
      end
      list = PDD::Sources.new(dir).fetch
      assert_equal exts.size, list.size
    end
  end

  def test_detects_xml_file
    Dir.mktmpdir 'test' do |dir|
      File.write(File.join(dir, 'a.xml'), '<?xml version="1.0"?><hello/>')
      list = PDD::Sources.new(dir).fetch
      assert_equal 1, list.size
    end
  end
end
