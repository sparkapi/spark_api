module SparkApi
  # API Response interface
  module Response
    ATTRIBUTES = [:code, :message, :results, :success, :pagination, :details]
    attr_accessor *ATTRIBUTES
    def success?
      @success
    end
  end

  # Nice and handy class wrapper for the api response hash
  class ApiResponse < ::Array
    include SparkApi::Response
    ROOT_KEY       = 'D'
    MESSAGE_KEY    = 'Message'
    CODE_KEY       = 'Code'
    RESULTS_KEY    = 'Results'
    SUCCESS_KEY    = 'Success'
    PAGINATION_KEY = 'Pagination'
    DETAILS_KEY    = 'Details'

    def initialize(d)
      begin
        hash = d[ROOT_KEY]
        if hash.nil? || hash.empty?
          raise InvalidResponse, 'The server response could not be understood'
        end
        self.message    = hash[MESSAGE_KEY]
        self.code       = hash[CODE_KEY]
        self.results    = Array(hash[RESULTS_KEY])
        self.success    = hash[SUCCESS_KEY]
        self.pagination = hash[PAGINATION_KEY]
        self.details    = hash[DETAILS_KEY] || []
        super(results)
      rescue Exception => e
        SparkApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
  end
end
