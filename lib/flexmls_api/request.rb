
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
      request_opts.merge!({"ApiSig" => sig})
      request_path = "#{path}?ApiSig=#{sig}#{build_url_parameters(request_opts)}"
      response = connection.send(method, request_path)
      response.body["D"]["Results"]
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
  
  class ApiResponse
  end

end
