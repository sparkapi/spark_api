

module FlexmlsApi
  module Connection

    def connection
      opts = {}

      Faraday::Connection.new(options) do |conn|
        connection.use Faraday::Response::ParseJson
      end
    end


  end
end
