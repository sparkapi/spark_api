require "rubygems"
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'ci/reporter/rake/rspec'
require "rspec"
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "flexmls_api"
    gemspec.summary = "A library for interacting with the flexmls web services."
    gemspec.description = "A library for interacting with the flexmls web services."
    gemspec.email = "bhornseth@fbsdata.com"
    gemspec.homepage = "http://www.flexmls.com"
    gemspec.authors = ["Brandon Hornseth"]
    gemspec.add_development_dependency "rspec"
    gemspec.add_development_dependency "jeweler"
    gemspec.add_development_dependency "curb"
    gemspec.add_development_dependency "json"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = %w{--exclude /usr/local/rvm/gems/,bundle,spec}
end

task :install do
  require './lib/flexmls_api'
  rm_rf "*.gem"
  puts `gem build flexmls_api.gemspec`
  puts `sudo gem install flexmls_api-#{FlexmlsApi::VERSION}.gem`
end

desc "Run all the tests"
task :default => :spec

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end 

Rake::RDocTask.new do |rdoc|
  files =['lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md" # page to start on
  rdoc.title = "flexmls_api Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

remove_task 'release'
remove_task 'rubygems:release'

spec = Gem::Specification::load("flexmls_api.gemspec")
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

task :deploy do
  gems = FileList['pkg/*.gem']
  FileUtils.cp gems, '/opt/gems/dev/gems'
  require 'rubygems'
  require 'rubygems/indexer'
  i=Gem::Indexer.new '/opt/gems/dev'
  i.generate_index
end
