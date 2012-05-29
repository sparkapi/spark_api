module SparkApi
  module Authentication
    class SimpleProvider < BaseOAuth2Provider
      def initialize(credentials)
        super(credentials)
        @grant_type = :authorization_code
      end

      def load_session
        @session
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
