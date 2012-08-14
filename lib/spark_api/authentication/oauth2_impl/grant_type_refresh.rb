module SparkApi
  module Authentication
    # OAuth2 authentication flow to refresh an access token
    module OAuth2Impl
      class GrantTypeRefresh < GrantTypeBase
        attr_accessor :params
        def initialize(client, provider, session)
          super(client, provider, session)
          @params = {}
        end
        
        def authenticate
          new_session = nil
          unless @session.refresh_token.nil?
            SparkApi.logger.debug("[oauth2] Refreshing authentication to #{provider.access_uri} using [#{session.refresh_token}]")
            new_session = create_session(token_params)
          end
          new_session 
        end
        
        private 
        def token_params
          hash = @params.merge({
            "client_id" => @provider.client_id,
            "client_secret" => @provider.client_secret,
            "grant_type" => "refresh_token",
            "refresh_token"=> session.refresh_token,
          }) 
          MultiJson.dump(hash)
        end
      end
      
    end
  end
end

