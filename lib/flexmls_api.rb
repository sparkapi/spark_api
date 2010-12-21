# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'
require 'logger'

require File.expand_path('../flexmls_api/version', __FILE__)
require File.expand_path('../flexmls_api/configuration', __FILE__)
require File.expand_path('../flexmls_api/authentication', __FILE__)
require File.expand_path('../flexmls_api/request', __FILE__)
require File.expand_path('../flexmls_api/base', __FILE__)
require File.expand_path('../flexmls_api/request', __FILE__)
require File.expand_path('../flexmls_api/client', __FILE__)
require File.expand_path('../flexmls_api/faraday', __FILE__)

# model classes
require File.expand_path('../flexmls_api/models/model_base', __FILE__)
require File.expand_path('../flexmls_api/models/listing', __FILE__)
require File.expand_path('../flexmls_api/models/photo', __FILE__)
require File.expand_path('../flexmls_api/models/system_info', __FILE__)
require File.expand_path('../flexmls_api/models/standard_fields', __FILE__)
require File.expand_path('../flexmls_api/models/property_types', __FILE__)
require File.expand_path('../flexmls_api/models/connect_prefs', __FILE__)

module FlexmlsApi
  extend Configuration
 
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
    @logger
  end

  def self.client(opts={})
    FlexmlsApi::Client.new(opts)
  end

  def self.method_missing(method, *args, &block)
    return super unless (client.respond_to?(method))
    client.send(method, *args, &block)
  end

end
