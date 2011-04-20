module FlexmlsApi
  module Models
    class Contact < Base
      extend Finders
      self.element_name="contacts"
      
      def save
        begin
          return save!
        rescue BadResourceRequest => e
        rescue NotFound => e
          # log and leave
          FlexmlsApi.logger.error("Failed to save contact #{self}: #{e.message}")
        end
        false
      end
      def save!
        results = connection.post self.class.path, "Contacts" => [ attributes ]
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        attributes['Id'] = result['ResourceUri'][/\/.*\/(.+)$/, 1]
        true
      end
    end
  end
end
