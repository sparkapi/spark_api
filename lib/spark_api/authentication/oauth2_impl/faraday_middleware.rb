require 'faraday'

module SparkApi
  module Authentication
    module OAuth2Impl
  
      #==OAuth2 Faraday response middleware
      # HTTP Response after filter to package oauth2 responses and bubble up basic api errors.
      class FaradayMiddleware < Faraday::Response::Middleware

        def initialize(app)
          super(app)
        end

        def on_complete(env)
          body = MultiJson.decode(env[:body])
          SparkApi.logger.debug { "[oauth2] Response Body: #{body.inspect}" }

          unless body.is_a?(Hash)
            raise InvalidResponse, "The server response could not be understood"
          end

          case env[:status]
          when 200..299
            SparkApi.logger.debug{ "[oauth2] Success!" }
            session = OAuthSession.new(body)
          else
            SparkApi.logger.warn { "[oauth2] failure #{body.inspect}" }

            # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
            # OAuth2 implementations and wouldn't hurt to log.
            auth_header_error = env[:request_headers]["WWW-Authenticate"]
            SparkApi.logger.warn { "Authentication error #{auth_header_error}" } unless auth_header_error.nil?
            raise ClientError, {:message => body["error"], :code =>0, :status => env[:status], :request_path => env[:url]}
          end
          SparkApi.logger.debug { "[oauth2] Session=#{session.inspect}" }
          env[:body] = session
        end

      end
      Faraday::Response.register_middleware :oauth2_impl => FaradayMiddleware
      
      #==OAuth2 Faraday response middleware
      # HTTP Response after filter to package oauth2 responses and bubble up basic api errors.
      class SparkbarFaradayMiddleware < Faraday::Response::Middleware
  
        def initialize(app)
          super(app)
        end
  
        def on_complete(env)
          body = MultiJson.decode(env[:body])
          SparkApi.logger.debug{ "[sparkbar] Response Body: #{body.inspect}" }
          unless body.is_a?(Hash)
            raise InvalidResponse, "The server response could not be understood"
          end
          case env[:status]
          when 200..299
            SparkApi.logger.debug{ "[sparkbar] Success!" }
            if body.include?("token")
              env[:body] = body
              return
            end
          end
          raise ClientError, {:message => "Unable to process sparkbar token #{body.inspect}", :code =>0, :status => env[:status], :request_path => env[:url]}
        end
  
      end
      Faraday::Response.register_middleware :sparkbar_impl => SparkbarFaradayMiddleware

    end
  end
end
