# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spark_api/version'
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
  
  s.add_dependency 'faraday', '~> 0.9.0'
  s.add_dependency 'multi_json', '~> 1.0'
  s.add_dependency 'json', '~> 1.7'
  s.add_dependency 'builder', '>= 2.1.2', '< 4.0.0'
  s.add_dependency 'will_paginate', '>= 3.0.pre2', '< 4.0.0'
  s.add_dependency 'highline', '>= 1.0'

  # TEST GEMS
  s.add_development_dependency 'rake', '~> 0.9.2'  
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'webmock', '~> 1.9'
  s.add_development_dependency 'typhoeus', '~> 0.3'
  s.add_development_dependency 'ci_reporter', '~> 1.7.0'
  s.add_development_dependency 'rcov', '~> 0.9.9'
  s.add_development_dependency 'rb-readline'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
end

