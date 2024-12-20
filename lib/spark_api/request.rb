require 'json'
require 'cgi'

module SparkApi
  # HTTP request wrapper.  Performs all the api session mumbo jumbo so that the models don't have to.
  module Request
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
      unless authenticated?
        authenticate
      end

      # Allow use of the X-HTTP-Method-Override header to disguise excessively
      # large GET/DELETE/HEAD requests as POST requests.
      if options[:http_method_override]
        options = options.clone
        options.delete(:http_method_override)
        body = URI.encode_www_form(options)
        options = {
          override_headers: {
            "X-HTTP-Method-Override" => method.to_s.upcase,
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        }
        method = :post
      end

      attempts = 0
      begin
        request_opts = {}
        request_opts.merge!(options)
        request_path = if middleware && middleware.to_sym == :reso_api
                         dd_version = "Dictionary/#{dictionary_version}/" unless dictionary_version.nil?
                         reso_version = "/Version/#{version}" unless version == SparkApi::Configuration::DEFAULT_VERSION || version.nil?
                         "#{reso_version}/Reso/#{dd_version}OData#{path}"
                       else
                         "/#{version}#{path}"
                       end
        start_time = Time.now
        if [:get, :delete, :head].include?(method.to_sym)
          response = authenticator.request(method, request_path, nil, request_opts)
        else
          post_data = process_request_body(body)
          if self.verbose
            SparkApi.logger.debug { "#{method.to_s.upcase} Data:   #{post_data}" }
          end
          response = authenticator.request(method, request_path, post_data, request_opts)
        end
        request_time = Time.now - start_time
        SparkApi.logger.debug { "[#{(request_time * 1000).to_i}ms] Api: #{method.to_s.upcase} #{request_path} request_id=#{response.headers['x-request-id']}" }
      rescue PermissionDenied => e
        if(ResponseCodes::SESSION_TOKEN_EXPIRED == e.code)
          unless (attempts +=1) > 1
            SparkApi.logger.debug { "Retrying authentication" }
            authenticate
            retry
          end
        end
        # No luck authenticating... KABOOM!
        SparkApi.logger.error { "Authentication failed or server is sending us expired tokens, nothing we can do here." }
        raise
      end

      if options[:full_response]
        return response
      else
        return response.body
      end
    rescue Faraday::ConnectionFailed => e
      if self.ssl_verify && e.message =~ /certificate verify failed/
        SparkApi.logger.error { SparkApi::Errors.ssl_verification_error }
      end
      raise e
    end
    
    def process_request_body(body)
      if body.is_a?(Hash) || body.is_a?(Array)
        body.empty? ? nil : {"D" => body }.to_json
      else
        body
      end
    end
    
  end
 
end
