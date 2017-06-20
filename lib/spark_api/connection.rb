require 'openssl'
require 'faraday'

module SparkApi
  # =Connection
  # Mixin module for handling http connection information
  module Connection
    # Main connection object for running requests.  Bootstraps the Faraday abstraction layer with 
    # our client configuration.
    def connection(force_ssl = false)
      opts = {
        :headers => headers
      }
      if(force_ssl || self.ssl)
        opts[:ssl] = {:verify => false } unless self.ssl_verify
        opts[:url] = @endpoint.sub /^http:/, "https:"
      else 
        opts[:url] = @endpoint.sub /^https:/, "http:"
      end

      if self.compress
        opts[:headers]["Accept-Encoding"] = 'gzip, deflate'
      end

      conn = Faraday.new(opts) do |conn|
        conn.response self.middleware.to_sym
        conn.options[:timeout] = self.timeout
        conn.adapter Faraday.default_adapter
      end
      SparkApi.logger.debug { "Connection: #{conn.inspect}" }
      conn
    end
    
    # HTTP request headers for client requests
    def headers
      if self.middleware.to_sym == :reso_api
        reso_headers
      else
        spark_headers
      end
    end

    def spark_headers
      {
        :accept => 'application/json',
        :content_type => 'application/json',
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_SPARK_API_USER_AGENT => user_agent
      }
    end

    def reso_headers
      {
        :accept => 'application/json, application/xml',
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_SPARK_API_USER_AGENT => user_agent
      }
    end
    
  end
end
