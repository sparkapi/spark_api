module SparkApi
  module Models
    class IdxLink < Base

      extend Finders
      include Defaultable
      
      self.element_name = "idxlinks"
      
      LINK_TYPES = ["QuickSearch", "SavedSearch", "MyListings", "Roster"]

    end
  end
end
