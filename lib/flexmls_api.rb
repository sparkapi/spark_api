# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'
require 'logger'

require File.expand_path('../flexmls_api/version', __FILE__)
require File.expand_path('../flexmls_api/configuration', __FILE__)
require File.expand_path('../flexmls_api/authentication', __FILE__)
require File.expand_path('../flexmls_api/paginate', __FILE__)
require File.expand_path('../flexmls_api/request', __FILE__)
require File.expand_path('../flexmls_api/client', __FILE__)
require File.expand_path('../flexmls_api/faraday', __FILE__)
require File.expand_path('../flexmls_api/models', __FILE__)

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
    Thread.current[:flexmls_api_client] ||= FlexmlsApi::Client.new(opts)
  end

  def self.method_missing(method, *args, &block)
    return super unless (client.respond_to?(method))
    client.send(method, *args, &block)
  end
  
  def self.reset
    reset_configuration
    Thread.current[:flexmls_api_client] = nil
  end

end
