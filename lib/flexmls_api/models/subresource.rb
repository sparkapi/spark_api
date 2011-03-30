module FlexmlsApi
  module Models
    module Subresource 
    
      def find_by_listing_key(key, arguments={})
        collect(connection.get("/listings/#{key}#{self.path}", arguments))
      end

    end
  end
end
