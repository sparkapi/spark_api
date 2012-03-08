require "rubygems"
require 'rubygems/user_interaction'
require 'flexmls_gems/tasks'
require 'flexmls_gems/tasks/spec'
require 'flexmls_gems/tasks/rdoc'

desc "Run all the tests"
task :default => :spec

desc "Generate (and test) supported flexmls API paths and methods"
RSpec::Core::RakeTask.new(:api_support) do |t|
  t.rspec_opts = ["--require spec/formatters/api_support_formatter",
                  "--format ApiSupportFormatter",
                  "--color",
                  "--tag support"]
  t.pattern = 'spec/unit/flexmls_api/models/**/*_spec.rb'
  t.verbose = false
end
