module FlexmlsApi
  # API Response interface
  module Response
    ATTRIBUTES = [:code, :message, :results, :success, :pagination, :details]
    attr_accessor *ATTRIBUTES
    def success?
      @success
    end
  end
  
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
    attr_reader :code, :status
    def initialize (options = {})
      # Support the standard initializer for errors
      opts = options.is_a?(Hash) ? options : {:message => options.to_s}
      @code = opts[:code]
      @status = opts[:status]
      super(opts[:message])
    end
    
  end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  class BadResourceRequest < ClientError; end
  
  # Nice and handy class wrapper for the api response hash
  class ApiResponse < ::Array
    include FlexmlsApi::Response
    def initialize(d)
      begin
        hash = d["D"]
        if hash.nil? || hash.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message    = hash["Message"]
        self.code       = hash["Code"]
        self.results    = Array(hash["Results"])
        self.success    = hash["Success"]
        self.pagination = hash["Pagination"]
        self.details    = hash["Details"] || []
        super(results)
      rescue Exception => e
        FlexmlsApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
  end
end