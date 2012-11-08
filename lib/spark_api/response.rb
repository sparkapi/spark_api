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
        SparkApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
  end
end
