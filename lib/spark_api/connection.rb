require 'openssl'
require 'faraday'

module SparkApi
  # =Connection
  # Mixin module for handling http connection information
  module Connection

    # Main connection object for running requests.  Bootstraps the Faraday abstraction layer with 
    # our client configuration.
    def connection(force_ssl = false)
      return @connection if @connection && !@connection.nil?
      opts = {
        :headers => headers
      }
      if(force_ssl || self.ssl)
        opts[:ssl] = {:verify => false } unless self.ssl_verify
        opts[:url] = @endpoint.sub /^http:/, "https:"
      else 
        opts[:url] = @endpoint.sub /^https:/, "http:"
      end

      conn = Faraday.new(opts) do |builder|
        builder.response :spark_api
        #builder.adapter Faraday.default_adapter
        builder.use Faraday::Adapter::Typhoeus
      end
      SparkApi.logger.debug("Connection: #{conn.inspect}")
      @connection = conn
    end
    
    # HTTP request headers for client requests
    def headers
      {
        :accept => 'application/json',
        :content_type => 'application/json',
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_SPARK_API_USER_AGENT => user_agent
      }
    end
    
  end
end
