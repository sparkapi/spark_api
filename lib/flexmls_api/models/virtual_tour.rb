module FlexmlsApi
  module Models
    class VirtualTour < Base
      self.element_name="virtualtours"
      
      def self.find_by_listing_key(key, api_user)
        vtours = []
        resp = connection.get("/listings/#{key}#{self.path}", :ApiUser => api_user)
        resp.collect { |tour| vtours.push(new(tour)) }
        vtours
      end


      def branded? 
        attributes["Type"] == "branded"
      end

      def unbranded?
        attributes["Type"] == "unbranded"
      end

    end
  end
end
