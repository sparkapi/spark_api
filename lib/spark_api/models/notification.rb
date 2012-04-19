module SparkApi
  module Models
    class Notification < Base

      self.element_name = 'notifications'

      def save(arguments={})
        self.errors = [] # clear the errors hash
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          self.errors << {:code => e.code, :message => e.message}
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        rescue NotFound => e
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end

      def save!(arguments={})
        results = connection.post self.class.path, attributes, arguments
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        true
      end

      def self.unread()
        # force pagination so response knows to deal with returned pagination info
        result = connection.get "#{self.path}/unread", {:_pagination => 'count'}
        result
      end

      def self.mark_read(notifications, arguments={})
        notifications = Array(notifications)

        ids = notifications.map { |n| n.respond_to?('Id') ? n.Id : n }
        result = connection.put "#{self.path}/#{ids.join(',')}", {'Read' => true}, arguments
      end

    end
  end
end
