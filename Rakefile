require "rubygems"
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
  t.rcov_opts = %w{--exclude bundle,spec}
end

task :install do
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

remove_task 'release'
remove_task 'rubygems:release'

