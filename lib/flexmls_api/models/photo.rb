module FlexmlsApi
  module Models
    class Photo < Base
      extend Subresource

      self.element_name = "photos"

      def primary? 
        @attributes["Primary"] == true 
      end


    end
  end
end
