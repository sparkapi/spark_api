module SparkApi
  module Models
    class Contact < Base
      extend Finders

      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="contacts"
      
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
        self.attributes[:Notify] == true
      end
      def notify=(notify_me=true)
        self.attributes[:Notify] = notify_me
      end
      
    end
  end
end
