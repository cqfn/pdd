# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

$stdout.sync = true

require 'simplecov'
SimpleCov.start

require 'simplecov-cobertura'
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

require 'minitest/autorun'
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
