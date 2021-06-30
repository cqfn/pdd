# Copyright (c) 2014-2021 Yegor Bugayenko
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

require 'nokogiri'
require 'tmpdir'
require 'slop'
require 'English'
require_relative '../../lib/pdd'

Before do
  @cwd = Dir.pwd
  @dir = Dir.mktmpdir('test')
  FileUtils.mkdir_p(@dir) unless File.exist?(@dir)
  Dir.chdir(@dir)
  @opts = Slop.parse ['-q', '-s', @dir] do |o|
    o.bool '-v', '--verbose'
    o.bool '-q', '--quiet'
    o.string '-s', '--source'
  end
end

After do
  Dir.chdir(@cwd)
  FileUtils.rm_rf(@dir) if File.exist?(@dir)
end

Given(/skip/) do
  skip_this_scenario
end

Given(/^I have a "([^"]*)" file with content:$/) do |file, text|
  FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(file)
  File.open(file, 'w:ASCII-8BIT') do |f|
    f.write(text.gsub(/\\xFF/, 0xFF.chr))
  end
end

When(/^I run pdd$/) do
  @xml = Nokogiri::XML.parse(PDD::Base.new(@opts).xml)
end

Then(/^XML matches "([^"]+)"$/) do |xpath|
  raise "XML doesn't match \"#{xpath}\":\n#{@xml}" if @xml.xpath(xpath).empty?
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
  raise "PDD didn't fail" if passed
end

When(%r{^I run bin/pdd with "([^"]*)"$}) do |arg|
  home = File.join(File.dirname(__FILE__), '../..')
  @stdout = `ruby -I#{home}/lib #{home}/bin/pdd #{arg}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

Then(/^Stdout contains "([^"]*)"$/) do |txt|
  unless @stdout.include?(txt)
    raise "STDOUT doesn't contain '#{txt}':\n#{@stdout}"
  end
end

Then(/^Stdout is empty$/) do
  raise "STDOUT is not empty:\n#{@stdout}" unless @stdout == ''
end

Then(/^XML file "([^"]+)" matches "([^"]+)"$/) do |file, xpath|
  raise "File #{file} doesn't exit" unless File.exist?(file)
  xml = Nokogiri::XML.parse(File.read(file))
  xml.remove_namespaces!
  if xml.xpath(xpath).empty?
    raise "XML file #{file} doesn't match \"#{xpath}\":\n#{xml}"
  end
end

Then(/^Exit code is zero$/) do
  raise "Non-zero exit code #{@exitstatus}" unless @exitstatus.zero?
end

Then(/^Exit code is not zero$/) do
  raise 'Zero exit code' if @exitstatus.zero?
end

When(/^I run bash with$/) do |text|
  FileUtils.copy_entry(@cwd, File.join(@dir, 'pdd'))
  @stdout = `#{text}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

When(/^I run bash with "([^"]*)"$/) do |text|
  FileUtils.copy_entry(@cwd, File.join(@dir, 'pdd'))
  @stdout = `#{text}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

Given(/^It is Unix$/) do
  pending if Gem.win_platform?
end

Given(/^It is Windows$/) do
  pending unless Gem.win_platform?
end
