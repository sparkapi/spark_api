# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'
require 'logger'


module FlexmlsApi
  require 'flexmls_api/authentication'
  require 'flexmls_api/client'

  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp
  
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
    end
    @logger
  end

end
