
module SparkApi

  class ResoFaradayMiddleware < FaradayMiddleware

    def on_complete(env)

      body = decompress_body(env)
      body = MultiJson.decode(body)

      if body["D"]
        puts "D contains #{body['D'].inspect}"
        super(env)
        return
      end

      env[:body] = body
    end

  end

  Faraday::Response.register_middleware :reso_api => ResoFaradayMiddleware
end
