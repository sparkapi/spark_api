
module FlexmlsApi
  module Authentication
    module OAuth2Impl
      class PasswordProvider < FlexmlsApi::Authentication::BaseOAuth2Provider
        def initialize(credentials)
          super(credentials)
          @grant_type = :password
        end
        
        def load_session()
          @session
        end
      
        def save_session(session)
          @session = session
        end
      
        def destroy_session
          @session = nil
        end
      end
    end
  end
end