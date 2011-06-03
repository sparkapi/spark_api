module FlexmlsApi
  module Models
    class Contact < Base
      extend Finders
      self.element_name="contacts"
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          FlexmlsApi.logger.error("Failed to save resource #{self}: #{e.message}")
        rescue NotFound => e
          FlexmlsApi.logger.error("Failed to save resource #{self}: #{e.message}")
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
      
      # Notify the agent of contact creation via a flexmls message.
      def notify?
        @notify == true
      end
      def notify=(notify_me=true)
        @notify = notify_me
      end
      
    end
  end
end
