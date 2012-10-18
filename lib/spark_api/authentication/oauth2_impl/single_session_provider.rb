module SparkApi
  module Authentication

    class SingleSessionProvider < BaseOAuth2Provider

      def initialize(credentials)
        @access_token = credentials.delete(:access_token)
        super(credentials)
      end

      def load_session
        @session ||= SparkApi::Authentication::OAuthSession.new({
          :access_token => @access_token
        })
      end

      def save_session session
        @session = session
      end

      def destroy_session
        @session = nil
      end

    end
  end
end
