require 'rubygems'
require 'rake'
require 'rdoc'

def name
  @name ||= File.basename(Dir['*.gemspec'].first, ".*")
end

def version
  Gem::Specification::load(Dir['*.gemspec'].first).version
end

task :default => [:test, :features]

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.profile = "travis"
end
Cucumber::Rake::Task.new(:"features:html", "Run Cucumber features and produce HTML output") do |t|
  t.profile = "html_report"
end
