module SparkApi
  module Models
    class Rule < Base

      self.element_name="listings/rules"

      def self.for_property_type(property_type, args={})
        collect(connection.get("/listings/rules/propertytypes/#{property_type}", args))
      end

    end
  end
end

