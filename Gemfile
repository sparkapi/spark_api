source :rubygems

# Refer to the flexmls_api.gemspec or Rakefile for dependency information
gemspec :development_group => :test

platforms :ruby do
  gem 'yajl-ruby'
end

platforms :jruby do
  gem 'jruby-openssl'
end

platforms :ruby_19 do
  group :test do
    gem 'ci_reporter', '~> 1.7.0'
    gem 'rcov', '0.9.9'
  end
end

