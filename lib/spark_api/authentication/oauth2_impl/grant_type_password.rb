module SparkApi
  module Authentication
    module OAuth2Impl
      # OAuth2 authentication flow using username and password parameters for the user in the 
      # request.  This implementation is geared towards authentication styles for native 
      # applications that need to use OAuth2
      class GrantTypePassword < GrantTypeBase
        def initialize(client, provider, session)
          super(client, provider, session)
        end
        def authenticate
          new_session = nil
          if needs_refreshing?
            new_session = refresh
          end
          return new_session unless new_session.nil?
          create_session(token_params)
        end
        
        def refresh()
          GrantTypeRefresh.new(client,provider,session).authenticate
        rescue ClientError => e
          SparkApi.logger.info("[oauth2] Refreshing token failed, the library will try and authenticate from scratch: #{e.message}")
          nil
        end

        private 
        def token_params
          params = {
            "client_id" => @provider.client_id,
            "client_secret" => @provider.client_secret,
            "grant_type" => "password",
            "username" => @provider.username,
            "password" => @provider.password,
          }.to_json 
        end
      end
    end
  end
end



 
