module FlexmlsApi

  module Authentication
    # Abstract class illustrating the interface for authentication systems
    class BaseAuth

      attr_accessor :session
      # All ihheriting classes should accept the flexmls_api client as part of instanciating
      def initialize(client)
        @client = client
      end
      
      def authenticate
        # overriden
      end
      
      def authenticated?
        !(session.nil? || session.expired?)
      end
      
      def logout
        # overriden
      end
        
      # Perform an HTTP request (no data)
      def request(method, path, body, options)
        # overriden
      end
      
      # Format a hash as request parameters
      # 
      # :returns:
      #   Stringized form of the parameters as needed for the http request
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
