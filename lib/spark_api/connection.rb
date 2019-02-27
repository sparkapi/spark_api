require 'openssl'
require 'faraday'

module SparkApi
  # =Connection
  # Mixin module for handling http connection information
  module Connection
    REG_HTTP  = /^http:/
    REG_HTTPS = /^https:/
    HTTP_SCHEME = 'http:'
    HTTPS_SCHEME = 'https:'
    ACCEPT_ENCODING = 'Accept-Encoding'
    COMPRESS_ACCEPT_ENCODING = 'gzip, deflate'
    X_REQUEST_ID_CHAIN = 'X-Request-Id-Chain'
    MIME_JSON = 'application/json'
    MIME_RESO = 'application/json, application/xml'
    # Main connection object for running requests.  Bootstraps the Faraday abstraction layer with 
    # our client configuration.
    def connection(force_ssl = false)
      opts = {
        :headers => headers
      }
      if(force_ssl || self.ssl)
        opts[:ssl] = {:verify => false } unless self.ssl_verify
        opts[:url] = @endpoint.sub REG_HTTP, HTTPS_SCHEME
      else 
        opts[:url] = @endpoint.sub REG_HTTPS, HTTP_SCHEME
      end

      if self.compress
        opts[:headers][ACCEPT_ENCODING] = COMPRESS_ACCEPT_ENCODING
      end

      if request_id_chain
        opts[:headers][X_REQUEST_ID_CHAIN] = request_id_chain
      end

      conn = Faraday.new(opts) do |conn|
        conn.response self.middleware.to_sym
        conn.options[:open_timeout] = self.open_timeout
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
        :accept => MIME_JSON,
        :content_type => MIME_JSON,
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_SPARK_API_USER_AGENT => user_agent
      }
    end

    def reso_headers
      {
        :accept => MIME_RESO,
        :user_agent => Configuration::DEFAULT_USER_AGENT,
        Configuration::X_SPARK_API_USER_AGENT => user_agent
      }
    end
    
  end
end
