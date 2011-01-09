module FlexmlsApi
  module Models
    module Subresource 
    
      def find_by_listing_key(key, user)
        collect(connection.get("/listings/#{key}#{self.path}", :ApiUser => user))
      end



    end
  end
end
