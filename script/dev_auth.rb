require 'spark_api'
require 'mechanize'


module Dev_auth

  attr_accessor :client

  def initialize_as_dev
    SparkApi.configure do |config|
      config.authentication_mode = SparkApi::Authentication::OpenIdOAuth2Hybrid
      config.api_key      = "#{ENV['SPARK_API_KEY']}"
      config.api_secret   = "#{ENV['SPARK_API_SECRET']}"
      config.callback     = "https://sparkplatform.com/oauth2/callback"
      config.auth_endpoint = "https://sparkplatform.com/openid"
      config.endpoint   = 'https://sparkapi.com'
    end
    @client = SparkApi.client
    @agent = Mechanize.new
  end

  def authenticate_as_dev
    page = @agent.get("#{@client.authenticator.authorization_url}") do |page|
      login_form = page.form_with(:action => '/ticket/login') do |f|
        username_field = f.field_with(:name => "user")
        username_field.value = "#{ENV['SPARK_USER']}"
        password_field = f.field_with(:name => "password")
        password_field.value = "#{ENV['SPARK_PASSWORD']}"
      @page = f.submit
      end
    end
    @token =  @page.title.split('=')[1]
    @client.oauth2_provider.code = "#{@token}"
    @client.authenticate
    @client.session = SparkApi::Authentication::OAuthSession.new "access_token"=> "#{@client.session.access_token}",
      "refresh_token" => "#{@client.session.refresh_token}", "expires_in" => 86400
  end

end


