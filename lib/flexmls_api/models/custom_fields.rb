module FlexmlsApi
  module Models
    class CustomFields < Base
      self.element_name="customfields"


      def self.find_by_property_type(card_fmt, user)
        collect(connection.get("#{self.path}/#{card_fmt}", :ApiUser => user))
      end
    end
  end
end
