require "rubygems"

Bundler.require(:default, "development") if defined?(Bundler)

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

class CLIOAuth2Provider < FlexmlsApi::Authentication::BaseOAuth2Provider
  def initialize(credentials)
    @authorization_uri = credentials[:authorization_uri]
    @access_uri        = credentials[:access_uri]
    @redirect_uri      = credentials[:redirect_uri]
    @client_id         = credentials[:client_id]
    @client_secret     = credentials[:client_secret]
    @username          = credentials[:username]
    @password          = credentials[:password]
    @session           = nil
  end

  def grant_type
    :password
  end
  
  def load_session()
    @session
  end

  def save_session(session)
    @session = session
  end

  def destroy_session
    @session = nil
  end
end

FlexmlsApi.logger.info("Client configured!")

FlexmlsApi.configure do |config|
  config.oauth2_provider = CLIOAuth2Provider.new(
                            :authorization_uri=> ENV["AUTH_URI"],
                            :access_uri  => ENV["ACCESS_URI"],
                            :username=> ENV["USERNAME"],
                            :password=> ENV["PASSWORD"],
                            :client_id=> ENV["CLIENT_ID"],
                            :client_secret=> ENV["CLIENT_SECRET"]
                          ) 
  config.authentication_mode = FlexmlsApi::Authentication::OAuth2
  config.endpoint = ENV["API_ENDPOINT"] if ENV["API_ENDPOINT"]
end

include FlexmlsApi::Models
