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
    gemspec.email = "api-support@flexmls.com"
    gemspec.homepage = "https://github.com/flexmls/flexmls_api"
    gemspec.authors = ["Brandon Hornseth", "Wade McEwen"]
    # Need to skip spec/reports for CI builds
    gemspec.files =  FileList["[A-Z]*", "{bin,lib,spec/fixtures,script,spec/unit}/**/*", "spec/*.rb"]
    # GEMS
    gemspec.add_dependency 'curb', '~> 0.7.15'
    gemspec.add_dependency 'faraday', '~> 0.6.1'
    gemspec.add_dependency 'faraday_middleware', '~> 0.6.3'
    gemspec.add_dependency 'multi_json', '~> 1.0.0'
    gemspec.add_dependency 'json', '~> 1.5.1'
    gemspec.add_dependency 'yajl-ruby', '~> 0.8.2'
    gemspec.add_dependency 'builder', '>= 2.1.2', '< 4.0.0'
    gemspec.add_dependency 'addressable', '~> 2.2.5'
    gemspec.add_dependency 'will_paginate', '>= 3.0.pre2', '< 4.0.0'
    # TEST GEMS
    gemspec.add_development_dependency 'rspec', '~> 2.3.0'
    gemspec.add_development_dependency 'webmock', '~> 1.4.0'
    gemspec.add_development_dependency 'jeweler', '~> 1.5.2'
    gemspec.add_development_dependency 'typhoeus', '~> 0.2.0'
    gemspec.add_development_dependency 'ci_reporter', '~> 1.6.3'
    gemspec.add_development_dependency 'rcov', '~> 0.9.9'
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
