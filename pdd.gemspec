# coding: utf-8
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '2.2.2'
  s.required_ruby_version = '>= 1.9.3'
  s.name = 'pdd'
  s.version = '1.0.pre'
  s.license = 'MIT'
  s.summary = "Puzzle Driven Development collector"
  s.description = "Collects puzzles from source code base"
  s.authors = ["Yegor Bugayenko"]
  s.email = 'yegor@teamed.io'
  s.homepage = 'http://github.com/teamed/pdd'
  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE.txt]
  s.add_runtime_dependency('trollop', '2.0')
  s.add_development_dependency('rake', "~> 10.1")
  s.add_development_dependency('rdoc', "~> 3.11")
  s.add_development_dependency('cucumber', "1.3.11")
end
