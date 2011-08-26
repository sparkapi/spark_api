# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'
require 'logger'

require 'flexmls_api/version'
require 'flexmls_api/configuration'
require 'flexmls_api/multi_client'
require 'flexmls_api/authentication'
require 'flexmls_api/paginate'
require 'flexmls_api/request'
require 'flexmls_api/client'
require 'flexmls_api/faraday'
require 'flexmls_api/primary_array'
require 'flexmls_api/models'

module FlexmlsApi
  extend Configuration
  extend MultiClient
 
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
