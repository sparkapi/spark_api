require 'cgi'

module FlexmlsApi
  # HTTP request wrapper.  Performs all the api session mumbo jumbo so that the models don't have to.
  module Request
    # Perform an HTTP GET request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
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
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def post(path, body={}, options={})
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
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def put(path, body={}, options={})
      request(:put, path, body, options)
    end

    # Perform an HTTP DELETE request
    # 
    # * path - Path of an api resource, excluding version and endpoint (domain) information
    # * options - Resource request options as specified being supported via and api resource
    # :returns:
    #   Hash of the json results as documented in the api.
    # :raises:
    #   FlexmlsApi::ClientError or subclass if the request failed.
    def delete(path, options={})
      request(:delete, path, nil, options)
    end
    
    private

    # Perform an HTTP request (no data)
    def request(method, path, body, options)
      unless authenticated?
        authenticate
      end
      attempts = 0
      begin
        request_opts = {}
        request_opts.merge!(options)
        post_data = body.nil? ? nil : {"D" => body }.to_json
        request_path = "/#{version}#{path}"
        start_time = Time.now
        FlexmlsApi.logger.debug("#{method.to_s.upcase} Request:  #{request_path}")
        if post_data.nil?
          response = authenticator.request(method, request_path, nil, request_opts)
        else
          FlexmlsApi.logger.debug("#{method.to_s.upcase} Data:   #{post_data}")
          response = authenticator.request(method, request_path, post_data, request_opts)
        end
        request_time = Time.now - start_time
        FlexmlsApi.logger.info("[#{(request_time * 1000).to_i}ms] Api: #{method.to_s.upcase} #{request_path}")
      rescue PermissionDenied => e
        if(ResponseCodes::SESSION_TOKEN_EXPIRED == e.code)
          unless (attempts +=1) > 1
            FlexmlsApi.logger.debug("Retrying authentication")
            authenticate
            retry
          end
        end
        # No luck authenticating... KABOOM!
        FlexmlsApi.logger.error("Authentication failed or server is sending us expired tokens, nothing we can do here.")
        raise
      end
      response.body
    end
    
  end
 
end
