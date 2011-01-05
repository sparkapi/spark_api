module FlexmlsApi
  module Models
    module Subresource 
    
      def find_by_listing_key(key, user)
        resources = []
        resp = connection.get("/listings/#{key}#{self.path}", :ApiUser => user)
        resp.collect { |r| resources.push(new(r)) }
        resources
      end



    end
  end
end
