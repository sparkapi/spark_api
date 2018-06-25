module SparkApi
  
  # All known response codes listed in the API
  module ResponseCodes
    NOT_FOUND = 404
    METHOD_NOT_ALLOWED = 405
    INVALID_KEY = 1000
    DISABLED_KEY = 1010
    API_USER_REQUIRED = 1015
    SESSION_TOKEN_EXPIRED = 1020
    SSL_REQUIRED = 1030
    INVALID_JSON = 1035
    INVALID_FIELD = 1040
    MISSING_PARAMETER = 1050
    INVALID_PARAMETER = 1053
    CONFLICTING_DATA = 1055
    NOT_AVAILABLE= 1500
    RATE_LIMIT_EXCEEDED = 1550
  end
  
  # Errors built from API responses
  class InvalidResponse < StandardError; end
  class ClientError < StandardError
    attr_reader :code, :status, :details, :request_path, :request_id, :errors
    def initialize (options = {})
      # Support the standard initializer for errors
      opts = options.is_a?(Hash) ? options : {:message => options.to_s}
      @code = opts[:code]
      @status = opts[:status]
      @details = opts[:details]
      @request_path = opts[:request_path]
      @request_id = opts[:request_id]
      @errors = opts[:errors]
      super(opts[:message])
    end
    
  end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  class BadResourceRequest < ClientError; end
   
  # =Errors
  # Error messages and other error handling
  module Errors
    def self.ssl_verification_error
      "SSL verification problem: if connecting to a trusted but non production API endpoint, " + 
      "set 'ssl_verify' to false in the configuration or add '--no_verify' to the CLI command."
    end
  end
end
