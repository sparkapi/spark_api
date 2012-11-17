# Lightweight example of an oauth2 provider used by the ruby client.
class TestOAuth2Provider < SparkApi::Authentication::BaseOAuth2Provider
  
  def initialize
    @authorization_uri = "https://test.fbsdata.com/r/oauth2"
    @access_uri = "https://api.test.fbsdata.com/v1/oauth2/grant"
    @redirect_uri = "https://exampleapp.fbsdata.com/oauth-callback"
    @client_id="example-id"
    @client_secret="example-password"    
    @sparkbar_uri = "https://test.sparkplatform.com/appbar/authorize"
    @session_cache = {}
  end
  
  def redirect(url)
    # User redirected to url, signs in, and gets code sent to callback
    self.code="my_code"
  end
  
  def load_session()
    @session_cache["test_user_session"]
  end
  
  def save_session(session)
    @session_cache["test_user_session"] = session
    nil
  end
  
  def session_timeout; 7200; end
  
end


class TestCLIOAuth2Provider < SparkApi::Authentication::BaseOAuth2Provider
  def initialize
    @authorization_uri = "https://test.fbsdata.com/r/oauth2"
    @access_uri = "https://api.test.fbsdata.com/v1/oauth2/grant"
    @client_id="example-id"
    @client_secret="example-secret"
    @username="example-user"
    @password="example-password"
    @session_cache = {}
  end
  
  def grant_type
    :password
  end
  
  def redirect(url)
    raise "Unsupported in oauth grant_type=password mode"
  end
  
  def load_session()
    @session_cache["test_user_session"]
  end
  def save_session(session)
    @session_cache["test_user_session"] = session
    nil
  end
  def session_timeout; 60; end
    
end


class InvalidAuth2Provider < SparkApi::Authentication::BaseOAuth2Provider
  
  def grant_type
    :not_a_real_type
  end
  
end
