require 'openssl'
require 'faraday'
require 'faraday_middleware'
require 'yajl'

module FlexmlsApi
  # =Connection
  # Mixin module for handling http connection information
  module Connection
    # Main connection object for running requests.  Bootstraps the Faraday abstraction layer with 
    # our client configuration.
    def connection(force_ssl = false)
      opts = {
        :headers => headers
      }
      domain = @endpoint 
      if(force_ssl || self.ssl)
        opts[:ssl] = {:verify => false }
        opts[:url] = @endpoint.sub /^http:/, "https:"
      else 
        opts[:url] = @endpoint.sub /^https:/, "http:"
      end
      conn = Faraday::Connection.new(opts) do |builder|
        builder.adapter Faraday.default_adapter
        builder.use FlexmlsApi::FaradayExt::FlexmlsMiddleware
      end
      FlexmlsApi.logger.debug("Connection: #{conn.inspect}")
      conn
    end
    
    # HTTP request headers for client requests
    def headers
      {
        :accept => 'application/json',
        :content_type => 'application/json',
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_FLEXMLS_API_USER_AGENT => user_agent
      }
    end
    
  end
end
