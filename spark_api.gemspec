# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "spark_api/version"
require 'rubygems/user_interaction'

Gem::Specification.new do |s|
  s.name        = "spark_api"
  s.version     = SparkApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brandon Hornseth", "Wade McEwen"]
  s.email       = %q{api-support@sparkapi.com}
  s.homepage    = %q{https://github.com/sparkapi/spark_api}
  s.summary     = %q{A library for interacting with the Spark web services.}
  s.description = %q{The spark_api gem handles most of the boilerplate for communicating with the Spark API rest services, including authentication and request parsing.}

  s.required_rubygems_version = ">= 1.8"
  s.required_ruby_version = '>= 2.2.4'
  s.rubyforge_project         = "spark_api"

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.license = 'Apache 2.0'

  s.files              = Dir["{History.txt,LICENSE,Rakefile,README.md,VERSION}", "{bin,lib,script}/**/*"]
  s.test_files         = Dir["spec/{fixtures,unit}/**/*", "spec/*.rb"]
  s.executables        = ["spark_api"]
  s.default_executable = %q{spark_api}
  s.require_paths      = ["lib"]
  
  s.add_dependency 'faraday', '~> 0.9.0'                      # 0.15.2   2018-05-23
  s.add_dependency 'multi_json'
  s.add_dependency 'json'
  s.add_dependency 'will_paginate'

  # TEST GEMS
  s.add_development_dependency 'rake', '~> 0.9.2'             # 12.3.1   2018-03-22
  s.add_development_dependency 'rspec', '~> 2.14.0'           # 3.7.0    2017-10-17
  s.add_development_dependency 'webmock', '~> 1.9'            # 3.4.2    2018-06-03
  s.add_development_dependency 'ci_reporter_rspec'
  s.add_development_dependency 'simplecov-rcov'
end

