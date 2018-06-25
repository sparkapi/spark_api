module SparkApi
  module Models
    class PropertyTypes < Base
      self.element_name="propertytypes"

      def self.all(options={})
        collect(connection.get("#{path}/all", options))
      end

    end
  end
end
