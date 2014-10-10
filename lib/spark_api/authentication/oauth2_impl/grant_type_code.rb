module SparkApi
  module Authentication
    module OAuth2Impl
      # OAuth2 authentication flow using username and password parameters for the user in the 
      # request.  This implementation is geared towards authentication styles for web applications
      # that have a OAuth flow for redirects.
      class GrantTypeCode < GrantTypeBase
        def initialize(client, provider, session)
          super(client, provider, session)
        end
        def authenticate
          if(provider.code.nil?)
            SparkApi.logger.debug { "[oauth2] No authoriztion code present. Redirecting to #{authorization_url}." }
            provider.redirect(authorization_url)
          end
          if needs_refreshing?
            new_session = refresh
          end
          return new_session unless new_session.nil?
          create_session(token_params)
        end
        
        def refresh()
          SparkApi.logger.debug { "[oauth2] Refresh oauth session." }
          refresher = GrantTypeRefresh.new(client,provider,session)
          refresher.params = {"redirect_uri" => @provider.redirect_uri}
          refresher.authenticate
        rescue ClientError => e
          SparkApi.logger.info { "[oauth2] Refreshing token failed, the library will try and authenticate from scratch: #{e.message}" }
          nil
        end

        private 
        def token_params
          hash = {
           "client_id" => @provider.client_id,
           "client_secret" => @provider.client_secret,
           "code" => @provider.code,
           "grant_type" => "authorization_code",
           "redirect_uri" => @provider.redirect_uri
         }
         MultiJson.dump(hash)
        end
        
      end
      
    end
  end
end
