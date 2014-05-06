require "rubygems"

require 'rubygems/user_interaction'

begin
  require "rcov"
  require 'flexmls_gems/tasks'
  require 'flexmls_gems/tasks/spec'
rescue LoadError => e
  require "rspec"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ["-c", "-f progress"]
    t.pattern = 'spec/**/*_spec.rb'
  end
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
