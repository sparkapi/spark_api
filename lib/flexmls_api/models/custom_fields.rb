module FlexmlsApi
  module Models
    class CustomFields < Base
      self.element_name="customfields"


      def self.find_by_property_type(card_fmt, arguments={})
        collect(connection.get("#{self.path}/#{card_fmt}", arguments))
      end
    end
  end
end
