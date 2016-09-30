module SparkApi
  # API Response interface
  module Response
    ATTRIBUTES = [:code, :message, :results, :success, :pagination, :details, :d]
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
        self.d = d["D"]
        if self.d.nil? || self.d.empty?
          raise InvalidResponse, "The server response could not be understood"
        end
        self.message    = self.d["Message"]
        self.code       = self.d["Code"]
        self.results    = Array(self.d["Results"])
        self.success    = self.d["Success"]
        self.pagination = self.d["Pagination"]
        self.details    = self.d["Details"] || []
        super(results)
      rescue Exception => e
        SparkApi.logger.error "Unable to understand the response! #{d}"
        raise
      end
    end
  end
end
