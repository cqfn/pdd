require 'rubygems'
require 'rake'
require 'rdoc'

def name
  @name ||= File.basename(Dir['*.gemspec'].first, '.*')
end

def version
  Gem::Specification.load(Dir['*.gemspec'].first).version
end

task default: [:test, :features, :rubocop]

require 'rake/testtask'
desc 'Run all unit tests'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rdoc/task'
desc 'Build RDoc documentation'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rubocop/rake_task'
desc 'Run RuboCop on the lib and test directories'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = [
    'pdd.gemspec', 'Rakefile',
    'lib/**/*.rb', 'features/**/*.rb', 'test/**/*.rb'
  ]
  task.fail_on_error = true
  task.requires << 'rubocop-rspec'
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.profile = 'travis'
end
Cucumber::Rake::Task.new(:"features:html") do |t|
  t.profile = 'html_report'
end
