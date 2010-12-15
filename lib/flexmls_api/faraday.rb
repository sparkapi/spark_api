module FlexmlsApi
  class ClientError < StandardError; end
  class NotFound < ClientError; end
  class PermissionDenied < ClientError; end
  class NotAllowed < ClientError; end
  
  module FaradayExt
    # Map status errors to appropriate api exceptions here.
    class ApiErrors < Faraday::Response::Middleware
      begin
        def self.register_on_complete(env)
          FlexmlsApi.logger.debug("Response: #{env.inspect}")
          env[:response].on_complete do |finished_env|
            case finished_env[:status]
            when 400
              raise "400"
            when 401
              raise PermissionDenied
            when 405
              raise NotAllowed
            when 500
              raise ClientError
            when 200
              FlexmlsApi.logger.debug("Success!")
            else 
              raise ClientError
            end
          end
        end
      rescue LoadError, NameError => e
        self.load_error = e
      end

      def initialize(app)
        super
        @parser = nil
      end

    end
  end
end