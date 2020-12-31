require 'faraday'
require 'cgi'
require 'zlib'

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
      env[:body] = decompress_body(env)

      begin
        body = MultiJson.decode(env[:body])
      rescue MultiJson::ParseError => e
        raise InvalidJSON, "Invalid JSON returned with HTTP #{env[:status]} for URI #{env[:url]}"
      end

      SparkApi.logger.debug{ "Response Body: #{body.inspect}" }
      unless body.is_a?(Hash) && body.key?("D")
        raise InvalidResponse, "The server response could not be understood"
      end
      request_id = env[:response_headers]['x-request-id']
      response = ApiResponse.new body, request_id
      paging = response.pagination

      if paging.nil?
        results = response
      else
        q = CGI.parse(env[:url].query)
        if q.key?("_pagination") && q["_pagination"].first == "count"
          results = paging['TotalRows']
        else
          results = paginate_response(response, paging)
        end
      end

      error_hash = {
        :request_path => env[:url],
        :request_id => request_id,
        :message => response.message,
        :code => response.code,
        :status => env[:status],
        :errors => body['D']['Errors']
      }

      case env[:status]
      when 400
        # constraint violation
        if response.code == 1053
          details = body['D']['Details']
          error_hash[:details] = details
        end
        raise BadResourceRequest, error_hash
      when 401
        # Handle the WWW-Authenticate Response Header Field if present. This can be returned by 
        # OAuth2 implementations and wouldn't hurt to log.
        auth_header_error = env[:request_headers]["WWW-Authenticate"]
        SparkApi.logger.warn("Authentication error #{auth_header_error}") unless auth_header_error.nil?
        raise PermissionDenied, error_hash
      when 404
        raise NotFound, error_hash
      when 405
        raise NotAllowed, error_hash
      when 409
        raise BadResourceRequest, error_hash
      when 500
        raise ClientError, error_hash
      when 200..299
        SparkApi.logger.debug { "Success!" }
      else 
        raise ClientError, error_hash
      end
      env[:body] = results
    end

    def decompress_body(env)
      encoding = env[:response_headers]['content-encoding'].to_s.downcase

      if encoding == 'gzip'
        env[:body] = Zlib::GzipReader.new(StringIO.new(env[:body])).read
      elsif encoding == 'deflate'
        env[:body] = Zlib::Inflate.inflate(env[:body])
      end

      env[:body]
    end
    
  end

  Faraday::Response.register_middleware :spark_api => FaradayMiddleware

end

