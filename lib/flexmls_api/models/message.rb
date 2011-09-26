module FlexmlsApi
  module Models
    class Message < Base
      self.element_name="messages"
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue NotFound, BadResourceRequest => e
          FlexmlsApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        results = connection.post self.class.path, {"Messages" => [ attributes ]}, arguments
        puts "MESSAGE RESULTS: #{results.inspect}"
        true
      end
      
    end
  end
end
