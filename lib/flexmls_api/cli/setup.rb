require "rubygems"
require 'pp'

if ENV["FLEXMLS_API_CONSOLE"].nil?
  require 'flexmls_api'
else
  puts "Enabling console mode for local gem"
  Bundler.require(:default, "development") if defined?(Bundler)
  path = File.expand_path(File.dirname(__FILE__) + "/../../../lib/")
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  require path + '/flexmls_api'
end

IRB.conf[:AUTO_INDENT]=true
IRB.conf[:PROMPT][:FLEXMLS]= {
  :PROMPT_I => "flexmlsApi:%03n:%i> ",
  :PROMPT_S => "flexmlsApi:%03n:%i%l ",
  :PROMPT_C => "flexmlsApi:%03n:%i* ",
  :RETURN => "%s\n"
} 

IRB.conf[:PROMPT_MODE] = :FLEXMLS

path = File.expand_path(File.dirname(__FILE__) + "/../../../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
require path + '/flexmls_api'

module FlexmlsApi
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = ENV["VERBOSE"].nil? ? Logger::WARN : Logger::DEBUG
    end
    @logger
  end
end

FlexmlsApi.logger.info("Client configured!")

include FlexmlsApi::Models

def c
  FlexmlsApi.client
end
