
module SparkApi
  class ResoFaradayMiddleware < FaradayMiddleware
    def on_complete(env)
      begin
        body = MultiJson.decode(env[:body])

        if body["D"]
          super(env)
          return
        end

        env[:body] = body
      rescue MultiJson::ParseError => e
        # We will allow the client to choose their XML parser, but should do
        # some minor format verification
        raise e if body.strip[/\A<\?xml/].nil?
      end
    end
  end

  Faraday::Response.register_middleware :reso_api => ResoFaradayMiddleware
end
