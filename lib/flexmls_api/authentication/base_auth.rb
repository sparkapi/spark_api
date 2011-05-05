module FlexmlsApi

  module Authentication
    #=Authentication Base
    # This base class defines the basic interface supported by all client authentication 
    # implementations.
    class BaseAuth
      attr_accessor :session
      # All ihheriting classes should accept the flexmls_api client as a part of initialization
      def initialize(client)
        @client = client
      end
      
      # Perform requests to authenticate the client with the API
      def authenticate
        # implement me
      end

      # Called prior to running authenticate (except in case of api authentication errors)
      def authenticated?
        !(session.nil? || session.expired?)
      end
      
      # Terminate the active session
      def logout
        # implement me
      end
        
      # Perform an HTTP request (no data)
      def request(method, path, body, options)
        # implement me
      end
      
      # Format a hash as request parameters
      # 
      # :returns:
      #   Stringized form of the parameters as needed for an HTTP request
      def build_url_parameters(parameters={})
        array = parameters.map do |key,value|
          escaped_value = CGI.escape("#{value}")
          "#{key}=#{escaped_value}"
        end
        array.join "&"
      end
    end
  end
end
