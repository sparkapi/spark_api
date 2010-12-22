module FlexmlsApi
  module FaradayExt
    # HTTP Response after filter to package api responses and bubble up basic api errors.
    class FlexmlsMiddleware < Faraday::Response::Middleware
      begin
        def self.register_on_complete(env)
          env[:response].on_complete do |finished_env|
            FlexmlsApi.logger.debug("hashed response: #{finished_env[:body]}")
            validate_and_build_response(finished_env)
          end
        end
      rescue LoadError, NameError => e
        self.load_error = e
      end
      
      def self.validate_and_build_response(finished_env)
        body = finished_env[:body]
        unless body.is_a?(Hash) && body.key?("D")
          raise InvalidResponse, "The server response could not be understood"
        end
        response = ApiResponse.new body
        case finished_env[:status]
        when 401
          raise PermissionDenied.new(response.code, finished_env[:status]), response.message
        when 405
          raise NotAllowed.new(response.code, finished_env[:status]), response.message
        when 500
          raise ClientError.new(response.code, finished_env[:status]), response.message
        when 200..299
          FlexmlsApi.logger.debug("Success!")
        else 
          raise ClientError.new(response.code, finished_env[:status]), response.message
        end
        finished_env[:body] = response
      end

      def initialize(app)
        super
        @parser = nil
      end
      
    end
  end
end