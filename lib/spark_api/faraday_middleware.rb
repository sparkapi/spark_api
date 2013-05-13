require 'faraday'
require 'cgi'

module SparkApi
  #=Spark API Faraday middleware
  # HTTP Response after filter to package api responses and bubble up basic api errors.
  class FaradayMiddleware < Faraday::Response::Middleware
    include SparkApi::PaginateHelper      
    
    def initialize(app)
      super(app)
    end

    # Handles pretty much all the api response parsing and error handling.  All responses that
    # indicate a failure will raise a SparkApi::ClientError exception
    def on_complete(env)
      body = MultiJson.decode(env[:body])
      SparkApi.logger.debug("Response Body: #{body.inspect}")
      unless body.is_a?(Hash) && body.key?("D")
        raise InvalidResponse, "The server response could not be understood"
      end
      api_response = ApiResponse.new body
      paging = api_response.pagination
      if paging.nil?
        results = api_response
      else
        q = CGI.parse(env[:url].query)
        if q.key?("_pagination") && q["_pagination"].first == "count"
          results = paging['TotalRows']
        else
          results = paginate_response(api_response, paging)
        end
      end
      raise_any_errors(env, body, api_response) unless SparkApi.client.connection.in_parallel?
      env[:body] = results
    end

    private

    def raise_any_errors(env, body, api_response)
      status = env[:status]
      case status
      when 400
        hash = {:message => api_response.message, :code => api_response.code, :status => status}

        # constraint violation
        if api_response.code == 1053
          details = body['D']['Details']
          hash[:details] = details
        end
        raise BadResourceRequest, hash
      when 401
        # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
        # OAuth2 implementations and wouldn't hurt to log.
        auth_header_error = env[:request_headers]["WWW-Authenticate"]
        SparkApi.logger.warn("Authentication error #{auth_header_error}") unless auth_header_error.nil?
        raise PermissionDenied, {:message => api_response.message, :code => api_response.code, :status => status}
      when 404
        raise NotFound, {:message => api_response.message, :code => api_response.code, :status => status}
      when 405
        raise NotAllowed, {:message => api_response.message, :code => api_response.code, :status => status}
      when 409
        raise BadResourceRequest, {:message => api_response.message, :code => api_response.code, :status => status}
      when 500
        raise ClientError, {:message => api_response.message, :code => api_response.code, :status => status}
      when 200..299
        SparkApi.logger.debug("Success!")
      else 
        raise ClientError, {:message => api_response.message, :code => api_response.code, :status => status}
      end
    end
    
  end
  Faraday.register_middleware :response, :spark_api => FaradayMiddleware

end
