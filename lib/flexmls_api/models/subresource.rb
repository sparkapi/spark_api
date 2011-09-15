module FlexmlsApi
  module Models
    module Subresource 
    
      def build_subclass
        Class.new(self)
      end

      def find_by_listing_key(key, arguments={})
        collect(connection.get("/listings/#{key}#{self.path}", arguments))
      end
      
      def find_by_id(id, parent_id, arguments={})
        collect(connection.get("/listings/#{parent_id}#{self.path}/#{id}", arguments)).first
      end
      
    end
  end
end
