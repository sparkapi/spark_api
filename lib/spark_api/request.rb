require 'spark_api/request/parallel'

require 'cgi'

module SparkApi
  # HTTP request wrapper.  Performs all the api session mumbo jumbo so that the models don't have to.
  module Request
    include Parallel

    # Perform an HTTP GET request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   SparkApi::ClientError or subclass if the request failed.
    def get(path, options={})
      request(:get, path, nil, options)
    end

    # Perform an HTTP POST request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * body - Hash for post body data
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   SparkApi::ClientError or subclass if the request failed.
    def post(path, body = nil, options={})
      request(:post, path, body, options)
    end

    # Perform an HTTP PUT request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * body - Hash for post body data
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   SparkApi::ClientError or subclass if the request failed.
    def put(path, body = nil, options={})
      request(:put, path, body, options)
    end

    # Perform an HTTP DELETE request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   SparkApi::ClientError or subclass if the request failed.
    def delete(path, options={})
      request(:delete, path, nil, options)
    end
    
    private

    # Perform an HTTP request (no data)
    def request(method, path, body, options)
      authenticate unless authenticated?

      request_path = "/#{version}#{path}"
      request_opts = options
      attempts = 0
      start_time = Time.now

      post_data = nil
      unless [:get, :delete, :head].include?(method.to_sym)
        post_data = process_request_body(body)
      end

      begin
        pre_log_request method, request_path, post_data
        response = authenticator.request(method, request_path, post_data, request_opts)
        post_log_request method, request_path, start_time
      rescue PermissionDenied => e
        if(ResponseCodes::SESSION_TOKEN_EXPIRED == e.code)
          if (attempts += 1) <= 1
            SparkApi.logger.debug("Retrying authentication")
            authenticate
            retry
          end
        end
        # No luck authenticating... KABOOM!
        SparkApi.logger.error("Authentication failed or server is sending us expired tokens, nothing we can do here.")
        raise
      end

      process_response response

    rescue Faraday::Error::ConnectionFailed => e
      if self.ssl_verify && e.message =~ /certificate verify failed/
        SparkApi.logger.error(SparkApi::Errors.ssl_verification_error)
      end
      raise e
    end

    def pre_log_request(method, request_path, post_data)
      SparkApi.logger.debug("#{method.to_s.upcase} Request:  #{request_path}")
      if ![:get, :delete, :head].include?(method.to_sym)
        SparkApi.logger.debug("#{method.to_s.upcase} Data:   #{post_data}")
      end
    end

    def post_log_request(method, request_path, start_time)
      description = "Api: #{method.to_s.upcase} #{request_path}"

      if connection.in_parallel?
        SparkApi.logger.info("  #{description}")
      else
        request_time = Time.now - start_time
        SparkApi.logger.info("[#{(request_time * 1000).to_i}ms] #{description}")
      end
    end
    
    def process_request_body(body)
      if body.is_a?(Hash)
        body.empty? ? nil : {"D" => body }.to_json
      else
        body
      end
    end

    def process_response(response)
      if connection.in_parallel?
        @parallel_responses << response
        response
      else
        response.body
      end
    end
    
  end
 
end
