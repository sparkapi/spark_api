module FlexmlsApi

  module Authentication

    #=API Authentication
    # Auth implementation for the API's original hash based authentication design.  This is the 
    # default authentication strategy used by the client.  API Auth rely's on the user's API key
    # and secret and the active user is tied to the key owner.  
    
    #==ApiAuth
    # Implementation the BaseAuth interface for API style authentication  
    class ApiAuth < BaseAuth
      
      def initialize(client)
        @client = client
      end
      
      def authenticate
        sig = sign("#{@client.api_secret}ApiKey#{@client.api_key}")
        FlexmlsApi.logger.debug("Authenticating to #{@client.endpoint}")
        start_time = Time.now
        request_path = "/#{@client.version}/session?ApiKey=#{@client.api_key}&ApiSig=#{sig}"
        resp = @client.connection(true).post request_path, ""
        request_time = Time.now - start_time
        FlexmlsApi.logger.info("[#{(request_time * 1000).to_i}ms] Api: POST #{request_path}")
        FlexmlsApi.logger.debug("Authentication Response: #{resp.inspect}")
        @session = Session.new(resp.body.results.first)
        FlexmlsApi.logger.debug("Authentication: #{@session.inspect}")
        @session
      end
      
      def logout
        @client.delete("/session/#{@session.auth_token}") unless @session.nil?
        @session = nil
      end
      
      # Builds an ordered list of key value pairs and concatenates it all as one big string.  Used 
      # specifically for signing a request.
      def build_param_string(param_hash)
        return "" if param_hash.nil?
          sorted = param_hash.sort do |a,b|
            a.to_s <=> b.to_s
          end
          params = ""
          sorted.each do |key,val|
            params += key.to_s + val.to_s
          end
          params
      end

      # Sign a request
      def sign(sig)
        Digest::MD5.hexdigest(sig)
      end
  
      # Sign a request with request data.
      def sign_token(path, params = {}, post_data="")
        sign("#{@client.api_secret}ApiKey#{@client.api_key}ServicePath#{path}#{build_param_string(params)}#{post_data}")
      end
      
      # Perform an HTTP request (no data)
      def request(method, path, body, options)
        escaped_path = URI.escape(path)
        request_opts = {
          "AuthToken" => @session.auth_token
        }
        unless @client.api_user.nil?
          request_opts.merge!(:ApiUser => "#{@client.api_user}")
        end
        request_opts.merge!(options)
        sig = sign_token(escaped_path, request_opts, body)
        request_path = "#{escaped_path}?#{build_url_parameters({"ApiSig"=>sig}.merge(request_opts))}"
        FlexmlsApi.logger.debug("Request: #{request_path}")
        if body.nil?
          response = @client.connection.send(method, request_path)
        else
          FlexmlsApi.logger.debug("Data: #{body}")
          response = @client.connection.send(method, request_path, body)
        end
        response
      end
      
    end
    
    # ==Session class
    # Handle on the api user session information as return by the api session service, including 
    # roles, tokens and expiration
    class Session
      attr_accessor :auth_token, :expires, :roles 
      def initialize(options={})
        @auth_token = options["AuthToken"]
        @expires = DateTime.parse options["Expires"]
        @roles = options["Roles"]
      end
      #  Is the user session token expired?
      def expired?
        DateTime.now > @expires
      end
    end

  end
end
