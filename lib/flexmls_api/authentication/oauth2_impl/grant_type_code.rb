
module FlexmlsApi
  module Authentication
    module OAuth2Impl
      # OAuth2 authentication flow using username and password parameters for the user in the 
      # request.  This implementation is geared towards authentication styles for web applications
      # that have a OAuth flow for redirects.
      class GrantTypeCode < GrantTypeBase
        attr_reader :provider
        def initialize(client, provider, session)
          super(client, provider, session)
        end
        def authenticate
          if(provider.code.nil?)
            FlexmlsApi.logger.debug("Redirecting to provider to get the authorization code")
            provider.redirect(authorization_url)
          end
          if needs_refreshing?
            new_session = refresh
          end
          return new_session unless new_session.nil?
          create_session(token_params)
        end
        
        def refresh()
          refresher = GrantTypeRefresh.new(client,provider,session)
          refresher.params = {"redirect_uri" => @provider.redirect_uri}
          refresher.authenticate
        rescue ClientError => e
          FlexmlsApi.logger.info("Refreshing token failed, the library will try and authenticate from scratch: #{e.message}")
          nil
        end

        private 
        def token_params
          params = {
            "client_id" => @provider.client_id,
            "client_secret" => @provider.client_secret,
            "grant_type" => "authorization_code",
            "code" => @provider.code,
            "redirect_uri" => @provider.redirect_uri
          }.to_json 
        end
        
      end
      
    end
  end
end
