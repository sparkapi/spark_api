module SparkApi
  module Models
    class Contact < Base
      extend Finders
      self.element_name="contacts"
      
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
        results = connection.post self.class.path, {"Contacts" => [ attributes ], "Notify" => notify? }, arguments
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        attributes['Id'] = parse_id(result['ResourceUri'])
        true
      end
      
      def self.by_tag(tag_name, arguments={})
        collect(connection.get("#{path}/tags/#{tag_name}", arguments))
      end

      def self.tags(arguments={})
        connection.get("#{path}/tags", arguments)
      end

      def self.my(arguments={})
        new(connection.get('/my/contact', arguments).first)
      end
            
      # Notify the agent of contact creation via a Spark notification.
      def notify?
        @notify == true
      end
      def notify=(notify_me=true)
        @notify = notify_me
      end
      
    end
  end
end
