require 'rubygems'
require 'logger'
require 'multi_json'

require 'spark_api/version'
require 'spark_api/errors'
require 'spark_api/configuration'
require 'spark_api/multi_client'
require 'spark_api/authentication'
require 'spark_api/response'
require 'spark_api/paginate'
require 'spark_api/request'
require 'spark_api/connection'
require 'spark_api/client'
require 'spark_api/faraday_middleware'
require 'spark_api/primary_array'
require 'spark_api/options_hash'
require 'spark_api/models'

module SparkApi
  extend Configuration
  extend MultiClient
 
  #:nocov:
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
    @logger
  end

  def self.logger= logger
    @logger = logger
  end
  #:nocov:

  def self.client(opts={})
    Thread.current[:spark_api_client] ||= SparkApi::Client.new(opts)
  end

  def self.method_missing(method, *args, &block)
    return super unless (client.respond_to?(method))
    client.send(method, *args, &block)
  end
  
  def self.reset
    reset_configuration
    Thread.current[:spark_api_client] = nil
  end

end
