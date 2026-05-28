# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'
require 'nokogiri'
require 'slop'
require 'tmpdir'
require_relative '../../lib/pdd'

Before do
  @cwd = Dir.pwd
  @dir = Dir.mktmpdir('test')
  FileUtils.mkdir_p(@dir)
  Dir.chdir(@dir)
  @opts =
    Slop.parse(['-q', '-s', @dir]) do |o|
      o.bool('-v', '--verbose')
      o.bool('-q', '--quiet')
      o.string('-s', '--source')
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
  raise(StandardError, "XML doesn't match \"#{xpath}\":\n#{@xml}") \
    if @xml.xpath(xpath).empty?
end

When(/^I run pdd it fails with "([^"]*)"$/) do |txt|
  begin
    PDD::Base.new(@opts).xml
    passed = true
  rescue PDD::Error => e
    unless e.message.include?(txt)
      raise(
        StandardError,
        "PDD failed but exception doesn't contain \"#{txt}\": #{e.message}"
      )
    end
  end
  raise(StandardError, "PDD didn't fail") if passed
end

When(%r{^I run bin/pdd with "([^"]*)"$}) do |arg|
  home = File.join(File.dirname(__FILE__), '../..')
  @stdout = `ruby -I#{home}/lib #{home}/bin/pdd #{arg}`
  @exitstatus = $CHILD_STATUS.exitstatus
end

Then(/^Stdout contains "([^"]*)"$/) do |txt|
  raise(StandardError, 'STDOUT is empty!') if @stdout.empty?
  raise(StandardError, "STDOUT doesn't contain '#{txt}':\n#{@stdout}") \
    unless @stdout.include?(txt)
end

Then(/^Stdout is empty$/) do
  raise(StandardError, "STDOUT is not empty:\n#{@stdout}") unless @stdout == ''
end

Then(/^XML file "([^"]+)" matches "([^"]+)"$/) do |file, xpath|
  raise(StandardError, "File #{file} doesn't exit") unless File.exist?(file)
  xml = Nokogiri::XML.parse(File.read(file))
  xml.remove_namespaces!
  raise(StandardError, "XML file #{file} doesn't match \"#{xpath}\":\n#{xml}") \
    if xml.xpath(xpath).empty?
end

Then(/^Text File "([^"]+)" contains "([^"]+)"$/) do |file, substring|
  raise(StandardError, "File #{file} doesn't exist") unless File.exist?(file)
  content = File.read(file)
  raise(StandardError, "File #{file} doesn't contain \"#{substring}\":\n#{content}") \
    if content.index(substring).nil?
end

Then(/^Exit code is zero$/) do
  raise(StandardError, "Non-zero exit code #{@exitstatus}") unless @exitstatus.zero?
end

Then(/^Exit code is not zero$/) do
  raise(StandardError, 'Zero exit code') if @exitstatus.zero?
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
