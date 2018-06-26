module SparkApi
  # API Response interface
  module Response
    ATTRIBUTES = [:code, :message, :results, :success, :pagination, :details, :d, :errors, :sparkql_errors, :request_id]
    attr_accessor *ATTRIBUTES
    def success?
      @success
    end
  end
  
  # Nice and handy class wrapper for the api response hash
  class ApiResponse < ::Array
    MAGIC_D = 'D'
    MESSAGE = 'Message'
    CODE = 'Code'
    RESULTS = 'Results'
    SUCCESS = 'Success'
    PAGINATION = 'Pagination'
    DETAILS = 'Details'
    ERRORS = 'Errors'
    SPARKQL_ERRORS = 'SparkQLErrors'
    include SparkApi::Response
    def initialize d, request_id=nil
      begin
        self.d = d[MAGIC_D]
        if self.d.nil? || self.d.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message    = self.d[MESSAGE]
        self.code       = self.d[CODE]
        self.results    = Array(self.d[RESULTS])
        self.success    = self.d[SUCCESS]
        self.pagination = self.d[PAGINATION]
        self.details    = self.d[DETAILS] || []
        self.errors     = self.d[ERRORS]
        self.sparkql_errors = self.d[SPARKQL_ERRORS]
        self.request_id = request_id
        super(results)
      rescue Exception => e
        SparkApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
  end
end
