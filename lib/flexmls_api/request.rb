require 'cgi'

module FlexmlsApi
  # HTTP request wrapper.  Performs all the api session mumbo jumbo so that the models don't have to.
  module Request
    include PaginateResponse
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
      if @session.nil? || @session.expired?
        authenticate
      end
      attempts = 0
      begin
        request_opts = {
          "AuthToken" => @session.auth_token
        }
        unless self.api_user.nil?
          request_opts.merge!(:ApiUser => "#{api_user}")
        end
        request_opts.merge!(options)
        post_data = body.nil? ? nil : {"D" => body }.to_json
        sig = sign_token(path, request_opts, post_data)
        request_path = "/#{version}#{path}?ApiSig=#{sig}#{build_url_parameters(request_opts)}"
        FlexmlsApi.logger.debug("Request: #{request_path}")
        start_time = Time.now
        if post_data.nil?
          response = connection.send(method, request_path)
        else
          FlexmlsApi.logger.debug("Data: #{post_data}")
          response = connection.send(method, request_path, post_data)
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
      results = response.body.results
      paging = response.body.pagination
      unless paging.nil?
        results = paginate_response(results, paging)
      end
      results
    end
    
    # Format a hash as request parameters
    # 
    # :returns:
    #   Stringized form of the parameters as needed for the http request
    def build_url_parameters(parameters={})
      str = ""
      parameters.map do |key,value|
        escaped_value = CGI.escape("#{value}")
        str << "&#{key}=#{escaped_value}"
      end
      str
    end    
  end
  
  # All known response codes listed in the API
  module ResponseCodes
    NOT_FOUND = 404
    METHOD_NOT_ALLOWED = 405
    INVALID_KEY = 1000
    DISABLED_KEY = 1010
    API_USER_REQUIRED = 1015
    SESSION_TOKEN_EXPIRED = 1020
    SSL_REQUIRED = 1030
    INVALID_JSON = 1035
    INVALID_FIELD = 1040
    MISSING_PARAMETER = 1050
    INVALID_PARAMETER = 1053
    CONFLICTING_DATA = 1055
    NOT_AVAILABLE= 1500
    RATE_LIMIT_EXCEEDED = 1550
  end
  
  # Errors built from API responses
  class InvalidResponse < StandardError; end
  class ClientError < StandardError
    attr_reader :code, :status
    def initialize (code, status)
      @code = code
      @status = status
    end
  end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  class BadResourceRequest < ClientError; end
  
  
  # Nice and handy class wrapper for the api response hash
  class ApiResponse
    attr_accessor :code, :message, :results, :success, :pagination
    def initialize(d)
      begin
        hash = d["D"]
        if hash.nil? || hash.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message  = hash["Message"]
        self.code     = hash["Code"]
        self.results  = hash["Results"]
        self.success  = hash["Success"]
        self.pagination = hash["Pagination"]
      rescue Exception => e
        FlexmlsApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
    def success?
      @success
    end
  end

end
