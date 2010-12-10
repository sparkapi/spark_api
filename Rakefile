require "rubygems"
require "rspec"
require 'rspec/core/rake_task'
require 'lib/flexmls_api.rb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "flexmls_api"
    gemspec.summary = "A library for interacting with the flexmls web services."
    gemspec.description = "TODO"
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
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :install do
  rm_rf "*.gem"
  puts `gem build flexmls_api.gemspec`
  puts `sudo gem install flexmls_api-#{FlexmlsApi::VERSION}.gem`
end

desc "Run all the tests"
task :default => :spec

