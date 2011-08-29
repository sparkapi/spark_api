# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'flexmls_api/version'

Gem::Specification.new do |s|
  s.name        = "flexmls_api"
  s.version     = FlexmlsApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brandon Hornseth", "Wade McEwen"]
  s.email       = %q{api-support@flexmls.com}
  s.homepage    = %q{https://github.com/flexmls/flexmls_api}
  s.summary     = %q{A library for interacting with the flexmls web services.}
  s.description = %q{The FlexmlsApi gem handles most of the boilerplate for communicating with the flexmls API rest services, including authentication and request parsing.}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "flexmls_api"

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.files              = Dir["{History.txt,LICENSE,Rakefile,README.md,VERSION}", "{bin,lib,script}/**/*"]
  s.test_files         = Dir["spec/{fixtures,unit}/**/*", "spec/*.rb"]
  s.executables        = ["flexmls_api"]
  s.default_executable = %q{flexmls_api}
  s.require_paths      = ["lib"]
  
  s.add_dependency 'curb', '~> 0.7.15'
  s.add_dependency 'faraday', '~> 0.6.1'
  s.add_dependency 'faraday_middleware', '~> 0.6.3'
  s.add_dependency 'multi_json', '~> 1.0.0'
  s.add_dependency 'json', '~> 1.5.1'
  s.add_dependency 'yajl-ruby', '~> 0.8.2'
  s.add_dependency 'builder', '>= 2.1.2', '< 4.0.0'
  s.add_dependency 'addressable', '~> 2.2.5'
  s.add_dependency 'will_paginate', '>= 3.0.pre2', '< 4.0.0'
  # TEST GEMS
  s.add_development_dependency "rake"  
  s.add_development_dependency 'rspec', '~> 2.3.0'
  s.add_development_dependency 'webmock', '>= 1.4.0', '< 2.0.0'
  s.add_development_dependency 'typhoeus', '~> 0.2.0'
  s.add_development_dependency 'ci_reporter', '~> 1.6.3'
  s.add_development_dependency 'rcov', '~> 0.9.9'
  s.add_development_dependency 'flexmls_gems', '~> 0.2.1'
end

