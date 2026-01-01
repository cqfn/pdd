# SPDX-FileCopyrightText: Copyright (c) 2014-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

$stdout.sync = true

require 'simplecov'
require 'simplecov-cobertura'
unless SimpleCov.running
  SimpleCov.command_name('test')
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::CoberturaFormatter
    ]
  )
  SimpleCov.minimum_coverage 100
  SimpleCov.minimum_coverage_by_file 100
  SimpleCov.start do
    add_filter 'test/'
    add_filter 'vendor/'
    add_filter 'target/'
    track_files 'lib/**/*.rb'
    track_files '*.rb'
  end
end

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
Minitest.load :minitest_reporter

require_relative '../lib/pdd'

def stub_source_find_github_user(file, path = '')
  source = PDD::Source.new(file, path)
  verbose_source = PDD::VerboseSource.new(file, source)
  fake = proc do |info = {}|
    email, author = info.values_at(:email, :author)
    { 'login' => 'yegor256' } if email == 'yegor256@gmail.com' ||
                                 author == 'Yegor Bugayenko'
  end
  source.stub :find_github_user, fake do
    yield verbose_source
  end
end
