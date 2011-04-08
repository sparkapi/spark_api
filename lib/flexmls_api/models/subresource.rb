module FlexmlsApi
  module Models
    module Subresource 
    
      def build_subclass
        Class.new(self)
      end


      def find_by_listing_key(key, arguments={})
        collect(connection.get("/listings/#{key}#{self.path}", arguments))
      end

    end
  end
end
