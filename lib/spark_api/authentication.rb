
require 'date'

require 'spark_api/authentication/base_auth'
require 'spark_api/authentication/api_auth'
require 'spark_api/authentication/oauth2'

module SparkApi
  # =Authentication
  # Mixin module for handling client authentication and reauthentication to the spark api.  Makes 
  # use of the configured authentication mode (API Auth by default).
  module Authentication

    # Main authentication step.  Run before any api request unless the user session exists and is 
    # still valid.
    #
    # *returns*
    #   The user session object when authentication succeeds
    # *raises*
    #   SparkApi::ClientError when authentication fails
    def authenticate
      start_time = Time.now
      request_time = Time.now - start_time
      new_session = @authenticator.authenticate
      SparkApi.logger.info("[#{(request_time * 1000).to_i}ms]")
      SparkApi.logger.debug("Session: #{new_session.inspect}")
      new_session
    end

    # Test to see if there is an active session
    def authenticated?
      @authenticator.authenticated?
    end
    
    # Delete the current session
    def logout
      SparkApi.logger.info("Logging out.")
      @authenticator.logout
    end

    # Fetch the active session object
    def session
      @authenticator.session
    end
    # Save the active session object
    def session=(active_session)
      @authenticator.session=active_session
    end
 
  end
end
