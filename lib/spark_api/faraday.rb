module SparkApi
  module FaradayExt
    #=Spark API Faraday middleware
    # HTTP Response after filter to package api responses and bubble up basic api errors.
    class SparkMiddleware < Faraday::Response::ParseJson
      include SparkApi::PaginateHelper      
      # Handles pretty much all the api response parsing and error handling.  All responses that
      # indicate a failure will raise a SparkApi::ClientError exception
      def on_complete(finished_env)
        body = parse(finished_env[:body])
        SparkApi.logger.debug("Response Body: #{body.inspect}")
        unless body.is_a?(Hash) && body.key?("D")
          raise InvalidResponse, "The server response could not be understood"
        end
        response = ApiResponse.new body
        paging = response.pagination
        if paging.nil?
          results = response
        else
          if finished_env[:url].query_values["_pagination"] == "count"
            results = paging['TotalRows']
          else
            results = paginate_response(response, paging)
          end
        end
        case finished_env[:status]
        when 400
          hash = {:message => response.message, :code => response.code, :status => finished_env[:status]}

          # constraint violation
          if response.code == 1053
            details = body['D']['Details']
            hash[:details] = details
          end
          raise BadResourceRequest,hash
        when 401
          # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
          # OAuth2 implementations and wouldn't hurt to log.
          auth_header_error = finished_env[:request_headers]["WWW-Authenticate"]
          SparkApi.logger.warn("Authentication error #{auth_header_error}") unless auth_header_error.nil?
          raise PermissionDenied, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        when 404
          raise NotFound, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        when 405
          raise NotAllowed, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        when 409
          raise BadResourceRequest, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        when 500
          raise ClientError, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        when 200..299
          SparkApi.logger.debug("Success!")
        else 
          raise ClientError, {:message => response.message, :code => response.code, :status => finished_env[:status]}
        end
        finished_env[:body] = results
      end
      
      def initialize(app)
        super(app)
      end
      
    end
  end
end
