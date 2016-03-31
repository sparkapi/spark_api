module SparkApi
  module Models
    class IdxLink < Base

      extend Finders
      
      self.element_name = "idxlinks"
      
      LINK_TYPES = ["QuickSearch", "SavedSearch", "MyListings", "Roster"]

      def self.default(options = {})
        response = connection.get("/#{self.element_name}/default", options).first
        response.nil? ? nil : new(response)
      end

    end
  end
end
