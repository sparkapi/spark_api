module SparkApi

  module Authentication
    
    module OAuth2Impl
      
      #==OAuth2 Faraday response middleware
      # HTTP Response after filter to package oauth2 responses and bubble up basic api errors.
      class Middleware < Faraday::Response::ParseJson
        def on_complete(finished_env)
          body = parse(finished_env[:body])
          SparkApi.logger.debug("[oauth2] Response Body: #{body.inspect}")
          unless body.is_a?(Hash)
            raise InvalidResponse, "The server response could not be understood"
          end
          case finished_env[:status]
          when 200..299
            SparkApi.logger.debug("[oauth2] Success!")
            session = OAuthSession.new(body)
          else 
            # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
            # OAuth2 implementations and wouldn't hurt to log.
            auth_header_error = finished_env[:request_headers]["WWW-Authenticate"]
            SparkApi.logger.warn("Authentication error #{auth_header_error}") unless auth_header_error.nil?
            raise ClientError, {:message => body["error"], :code =>0, :status => finished_env[:status]}
          end
          SparkApi.logger.debug("[oauth2] Session=#{session.inspect}")
          finished_env[:body] = session
        end
    
        def initialize(app)
          super(app)
        end
        
      end
    end
  end
end
