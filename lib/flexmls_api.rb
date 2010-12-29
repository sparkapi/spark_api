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

# load model classes
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

  # Return the active client instance.  Note that this implementation is not currently threadsafe, so all threads 
  # better want the same client instance.
  def self.client(opts={})
    @client ||= FlexmlsApi::Client.new(opts)
  end

  def self.method_missing(method, *args, &block)
    return super unless (client.respond_to?(method))
    client.send(method, *args, &block)
  end

end
