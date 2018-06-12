module SparkApi
  module Models
    class ListingMetaTranslations < Base

      def self.for_property_type(pt, options={})
        results = connection.get("/flexmls/propertytypes/#{pt}/translations", options)
        if results.any?
          collect(results).first
        else
          new(StandardFields: {}, CustomFields: {})
        end
      end

    end
  end
end
