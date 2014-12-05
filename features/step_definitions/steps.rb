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

require 'pdd'
require 'nokogiri'
require 'tmpdir'
require 'slop'
require 'English'

Before do
  @cwd = Dir.pwd
  @dir = Dir.mktmpdir('test')
  FileUtils.mkdir_p(@dir) unless File.exist?(@dir)
  Dir.chdir(@dir)
  @opts = Slop.parse ['-v', '-s', @dir] do
    on 'v', 'verbose'
    on 's', 'source', argument: :required
  end
end

After do
  Dir.chdir(@cwd)
  FileUtils.rm_rf(@dir) if File.exist?(@dir)
end

Given(/^I have a "([^"]*)" file with content:$/) do |file, text|
  FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(file)
  File.open(file, 'w') do |f|
    f.write(text)
  end
end

When(/^I run pdd$/) do
  @xml = Nokogiri::XML.parse(PDD::Base.new(@opts).xml)
end

Then(/^XML matches "([^"]+)"$/) do |xpath|
  fail "XML doesn't match \"#{xpath}\":\n#{@xml}" if @xml.xpath(xpath).empty?
end

When(/^I run pdd it fails with "([^"]*)"$/) do |txt|
  begin
    PDD::Base.new(@opts).xml
    passed = true
  rescue PDD::Error => ex
    unless ex.message.include?(txt)
      raise "PDD failed but exception doesn't contain \"#{txt}\": #{ex.message}"
    end
  end
  fail "PDD didn't fail" if passed
end

When(/^I run bin\/pdd with "([^"]*)"$/) do |arg|
  home = File.join(File.dirname(__FILE__), '../..')
  @stdout = `ruby -I#{home}/lib #{home}/bin/pdd #{arg}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

Then(/^Stdout contains "([^"]*)"$/) do |txt|
  unless @stdout.include?(txt)
    fail "STDOUT doesn't contain '#{txt}':\n#{@stdout}"
  end
end

Then(/^Stdout is empty$/) do
  fail "STDOUT is not empty:\n#{@stdout}" unless @stdout == ''
end

Then(/^XML file "([^"]+)" matches "([^"]+)"$/) do |file, xpath|
  fail "File #{file} doesn't exit" unless File.exist?(file)
  xml = Nokogiri::XML.parse(File.read(file))
  xml.remove_namespaces!
  if xml.xpath(xpath).empty?
    fail "XML file #{file} doesn't match \"#{xpath}\":\n#{xml}"
  end
end

Then(/^Exit code is zero$/) do
  fail "Non-zero exit code #{@exitstatus}" unless @exitstatus == 0
end

Then(/^Exit code is not zero$/) do
  fail 'Zero exit code' if @exitstatus == 0
end

When(/^I run bash with$/) do |text|
  FileUtils.copy_entry(@cwd, File.join(@dir, 'pdd'))
  @stdout = `#{text}`
  @exitstatus = $CHILD_STATUS.exitstatus
end
