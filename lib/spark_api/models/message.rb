module SparkApi
  module Models
    class Message < Base
      extend Finders
      self.element_name="messages"
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          SparkApi.logger.warn("Failed to save resource #{self}: #{e.message}")
        rescue NotFound => e
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        results = connection.post self.class.path, {"Messages" => [ attributes ]}, arguments
        true
      end
      
    end
  end
end
