module FlexmlsApi
  module Models
    class Photo < Base

      def primary? 
        @attributes["Primary"] == true 
      end

      def self.find_by_listing_key(key, options = {})
        photos = []
        resp = FlexmlsApi.client.get("/listings/#{key}/photos", options)
        resp.collect { |photo| photos.push(new(photo)) }
        photos
      end

    end
  end
end
