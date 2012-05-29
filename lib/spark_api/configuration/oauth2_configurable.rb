module SparkApi
  module Configuration
    module OAuth2Configurable
      def convert_to_oauth2?
        self.authentication_mode == SparkApi::Authentication::OAuth2 &&
          self.oauth2_provider.nil? 
      end

      def oauth2_enabled?
        self.authentication_mode == SparkApi::Authentication::OAuth2
      end

      def oauthify!
        self.oauth2_provider = SparkApi::Authentication::SimpleProvider.new(
          :access_uri    => grant_uri,
          :client_id     => self.api_key,
          :client_secret => self.api_secret,
          :authorization_uri => self.auth_endpoint,
          :redirect_uri  => self.callback
        )
      end

      def grant_uri
        e = self.endpoint.gsub(/\/+$/,"")
        v = self.version.gsub(/\/+/,"/")
        "#{e}/#{v}/oauth2/grant"
      end
    end
  end
end
