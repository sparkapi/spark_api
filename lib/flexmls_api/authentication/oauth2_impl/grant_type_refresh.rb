
module FlexmlsApi
  module Authentication
    # OAuth2 authentication flow to refresh an access token
    module OAuth2Impl
      class GrantTypeRefresh < GrantTypeBase
        attr_accessor :params
        attr_reader :provider
        def initialize(client, provider, session)
          super(client, provider, session)
          @params = {}
        end
        
        def authenticate
          new_session = nil
          unless @session.refresh_token.nil?
            FlexmlsApi.logger.debug("Refreshing authentication to #{provider.access_uri} using [#{session.refresh_token}]")
            new_session = create_session(token_params)
          end
          new_session 
        end
        
        private 
        def token_params
          @params.merge({
            "client_id" => @provider.client_id,
            "client_secret" => @provider.client_secret,
            "grant_type" => "refresh_token",
            "refresh_token"=> session.refresh_token,
          }).to_json 
        end
      end
      
    end
  end
end

