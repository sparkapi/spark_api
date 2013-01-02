module SparkApi
  module Models
    class Fields < Base
      self.element_name="fields"

      def self.order(property_type=nil, arguments={})
        connection.get("#{self.path}/order#{"/"+property_type unless property_type.nil?}", arguments)
      end

    end
  end
end
