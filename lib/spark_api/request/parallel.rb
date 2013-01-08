module SparkApi
  module Request

    module Parallel

      def in_parallel(&block)
        connection.in_parallel(Faraday::Adapter::Typhoeus.setup_parallel_manager, &block)
      end

    end

  end
end
