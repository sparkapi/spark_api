require 'typhoeus'

module SparkApi
  module Request

    module Parallel

      HYDRA = Typhoeus::Hydra.new(:max_concurrency => 10) # (200 is default)
      #HYDRA.disable_memoization

      def in_parallel(&block)
        @parallel_responses = []
        start_time = Time.now
        SparkApi.logger.info "[Parallel Requests]"
        connection.in_parallel(HYDRA, &block)
        total_time = ((Time.now - start_time) * 1000).to_i
        SparkApi.logger.info "[#{total_time}ms] Total for (#{@parallel_responses.size}) parallel requests"
        @parallel_responses
      ensure
        @parallel_responses.clear
      end

    end

  end
end
