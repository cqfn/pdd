# SPDX-FileCopyrightText: Copyright (c) 2014-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/pdd/version'

Gem::Specification.new do |s|
  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version =
      Gem::Requirement.new('>= 0')
  end
  s.required_ruby_version = '>=2'
  s.name = 'pdd'
  s.version = PDD::VERSION
  s.license = 'MIT'
  s.summary = 'Puzzle Driven Development collector'
  s.description = 'Collects PDD puzzles from a source code base'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/cqfn/pdd'
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_runtime_dependency 'nokogiri', '~> 1.10'
  s.add_runtime_dependency 'rainbow', '~> 3.0'
  s.add_runtime_dependency 'ruby-filemagic', '~> 0.7.2'
  s.add_runtime_dependency 'slop', '~> 4.6'
  s.metadata['rubygems_mfa_required'] = 'true'
end
