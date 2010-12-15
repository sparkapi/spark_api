# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'
require 'logger'

require File.expand_path('../flexmls_api/configuration', __FILE__)
require File.expand_path('../flexmls_api/authentication', __FILE__)
require File.expand_path('../flexmls_api/connection', __FILE__)
require File.expand_path('../flexmls_api/request', __FILE__)
require File.expand_path('../flexmls_api/base', __FILE__)
require File.expand_path('../flexmls_api/client', __FILE__)
require File.expand_path('../flexmls_api/listing', __FILE__)

module FlexmlsApi
  extend Configuration

  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp
  
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
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
