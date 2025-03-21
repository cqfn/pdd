# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require 'tmpdir'
require 'slop'
require 'English'
require_relative '../../lib/pdd'

Before do
  @cwd = Dir.pwd
  @dir = Dir.mktmpdir('test')
  FileUtils.mkdir_p(@dir)
  Dir.chdir(@dir)
  @opts = Slop.parse ['-q', '-s', @dir] do |o|
    o.bool '-v', '--verbose'
    o.bool '-q', '--quiet'
    o.string '-s', '--source'
  end
end

After do
  Dir.chdir(@cwd)
  FileUtils.rm_rf(@dir)
end

Given(/skip test/) do
  skip_this_scenario
end

Given(/^I have a "([^"]*)" file with content:$/) do |file, text|
  FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(file)
  File.open(file, 'w:ASCII-8BIT') do |f|
    f.write(text.gsub('\\xFF', 0xFF.chr))
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
  rescue PDD::Error => e
    unless e.message.include?(txt)
      raise "PDD failed but exception doesn't contain \"#{txt}\": #{e.message}"
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
  raise 'STDOUT is empty!' if @stdout.empty?
  raise "STDOUT doesn't contain '#{txt}':\n#{@stdout}" unless @stdout.include?(txt)
end

Then(/^Stdout is empty$/) do
  raise "STDOUT is not empty:\n#{@stdout}" unless @stdout == ''
end

Then(/^XML file "([^"]+)" matches "([^"]+)"$/) do |file, xpath|
  raise "File #{file} doesn't exit" unless File.exist?(file)

  xml = Nokogiri::XML.parse(File.read(file))
  xml.remove_namespaces!
  raise "XML file #{file} doesn't match \"#{xpath}\":\n#{xml}" if xml.xpath(xpath).empty?
end

Then(/^Text File "([^"]+)" contains "([^"]+)"$/) do |file, substring|
  raise "File #{file} doesn't exist" unless File.exist?(file)

  content = File.read(file)
  raise "File #{file} doesn't contain \"#{substring}\":\n#{content}" \
    if content.index(substring).nil?
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
