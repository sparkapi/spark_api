
module FlexmlsApi
  
  module Request
    # Perform an HTTP GET request
    def get(path, options={})
      request(:get, path, options)
    end

    # Perform an HTTP POST request
    def post(path, options={})
      request(:post, path, options)
    end

    # Perform an HTTP PUT request
    def put(path, options={})
      request(:put, path, options)
    end

    # Perform an HTTP DELETE request
    def delete(path, options={})
      request(:delete, path, options)
    end

    private

    # Perform an HTTP request
    def request(method, path, options)
      if @session.nil? || @session.expired?
        authenticate
      end
      request_opts = {
        "AuthToken" => @session.auth_token
      }
      request_opts.merge!(options)
      sig = sign_token(path, request_opts)
      request_path = "/#{version}#{path}?ApiSig=#{sig}#{build_url_parameters(request_opts)}"
      response = connection.send(method, request_path)
      response.body.results
    end
    
    def build_url_parameters( parameters={} )
      str = []
      parameters.map do |key,value|
        str << "#{key}=#{value}"
      end
      if str.size > 0
        return "&" + str.join("&")
      end
      "" 
    end    
  end
  
  module ResponseCodes
    SESSION_TOKEN_EXPIRED = "1020"
  end
  
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
  
  # Nice and handy class wrapper for the api response json
  # TODO look into using hashie for this business. (https://github.com/intridea/hashie)
  class ApiResponse
    attr_accessor :code, :message, :count, :offset, :results, :success
    def initialize(d)
      begin
        hash = d["D"]
        if hash.nil? || hash.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message  = hash["Message"]
        self.code     = hash["Code"]
        self.count    = hash["Count"]
        self.offset   = hash["Offset"]
        self.results  = hash["Results"]
        self.success  = hash["Success"]
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
