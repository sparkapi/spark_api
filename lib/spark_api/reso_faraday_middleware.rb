
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
        # some minor format verification.
        # Note: the JSON decode above raised before assigning +body+, so the
        # local +body+ is still nil here. Reference the raw +env[:body]+
        # instead — that's what we actually want to inspect for an XML prolog.
        raise e if env[:body].to_s.strip[/\A<\?xml/].nil?
      end
    end
  end

  Faraday::Response.register_middleware :reso_api => ResoFaradayMiddleware
end
