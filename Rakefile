require "rubygems"

require 'rubygems/user_interaction'
require 'rspec'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ["-c", "-f progress"]
    t.pattern = 'spec/**/*_spec.rb'
end

desc "Run all the tests"
task :default => :spec

desc "Generate (and test) supported Spark API paths and methods"
RSpec::Core::RakeTask.new(:api_support) do |t|
  t.rspec_opts = ["--require spec/formatters/api_support_formatter",
                  "--format ApiSupportFormatter",
                  "--color",
                  "--tag support"]
  t.pattern = 'spec/unit/spark_api/models/**/*_spec.rb'
  t.verbose = false
end
