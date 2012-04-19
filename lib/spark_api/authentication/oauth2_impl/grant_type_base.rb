module SparkApi
  module Authentication
    module OAuth2Impl
      class GrantTypeBase
        GRANT_TYPES = [:authorization_code, :password, :refresh_token] 
        
        def self.create(client, provider, session=nil)
          granter = nil
          case provider.grant_type
          when :authorization_code
            granter = GrantTypeCode.new(client, provider, session)
          when :password
            granter = GrantTypePassword.new(client, provider, session)
          # This method should only be used internally to the library
          when :refresh_token
            granter = GrantTypeRefresh.new(client, provider, session)
          else
            raise ClientError, "Unsupported grant type [#{provider.grant_type}]"
          end
          SparkApi.logger.debug("[oauth2] setup #{granter.class.name}")
          granter
        end
        
        attr_reader :provider, :client, :session
        def initialize(client, provider, session)
          @client = client
          @provider = provider
          @session = session
        end
        def authenticate
          
        end
        
        def refresh
          
        end

        protected

        def create_session(token_params)
          SparkApi.logger.debug("[oauth2] create_session to #{provider.access_uri} params #{token_params}")
          uri = URI.parse(provider.access_uri)
          request_path = "#{uri.path}"
          response = oauth_access_connection("#{uri.scheme}://#{uri.host}").post(request_path, "#{token_params}").body
          response.expires_in = provider.session_timeout if response.expires_in.nil?
          SparkApi.logger.debug("[oauth2] New session created #{response}")
          response
        end
                
        def needs_refreshing?
          !@session.nil? && !@session.refresh_token.nil? && @session.expired?
        end
        
        # Generate the appropriate request uri for authorizing this application for current user.
        def authorization_url()
          params = {
            "client_id" => @provider.client_id,
            "response_type" => "code",
            "redirect_uri" => @provider.redirect_uri
          }
          "#{@provider.authorization_uri}?#{build_url_parameters(params)}"
        end
        
        # Setup a faraday connection for dealing with an OAuth2 endpoint
        def oauth_access_connection(endpoint)
          opts = {
            :headers => @client.headers
          }
          opts[:ssl] = {:verify => false }
          opts[:url] = endpoint       
          conn = Faraday::Connection.new(opts) do |builder|
            builder.adapter Faraday.default_adapter
            builder.use SparkApi::Authentication::OAuth2Impl::Middleware
          end
        end        
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
end
