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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdd/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new('>= 0')
  end
  s.rubygems_version = '2.2.2'
  s.required_ruby_version = '>= 1.9.3'
  s.name = 'pdd'
  s.version = PDD::VERSION
  s.license = 'MIT'
  s.summary = 'Puzzle Driven Development collector'
  s.description = 'Collects puzzles from source code base'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor@teamed.io'
  s.homepage = 'http://github.com/teamed/pdd'
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(/{^bin\/}/) { |f| File.basename(f) }
  s.test_files = s.files.grep(/{^(test|spec|features)\/}/)
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.3.1'
  s.add_runtime_dependency 'ruby-filemagic', '~> 0.6', '>= 0.6.0'
  s.add_runtime_dependency 'slop', '~> 3.6', '>= 3.6.0'
  s.add_runtime_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'coveralls', '~> 0.7', '>= 0.7.0'
  s.add_development_dependency 'rdoc', '~> 3.11'
  s.add_development_dependency 'cucumber', '1.3.11'
  s.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.0'
  s.add_development_dependency 'rubocop', '~> 0.24', '>= 0.24.1'
  s.add_development_dependency 'rubocop-rspec', '~> 1.1', '>= 1.1.0'
  s.add_development_dependency 'rspec-rails', '~> 2.13'
end
