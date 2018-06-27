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

      def replies(args = {})
        arguments = {:_expand => "Body, Sender"}.merge(args)
        Message.collect(connection.get("#{self.class.path}/#{self.Id}/replies", arguments))
      end

      def self.unread(args={})
        collect(connection.get("#{path}/unread", args))
      end

      def self.unread_count
        unread _pagination: 'count'
      end

    end
  end
end
