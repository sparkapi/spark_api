# Flexmlsapi
require 'rubygems'
require 'curb'
require 'json'


module FlexmlsApi
  require 'flexmls_api/authentication'
  require 'flexmls_api/client'

  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp
  
  def logger
    if @logger.nil?
    
    end
    @logger
  end
end
