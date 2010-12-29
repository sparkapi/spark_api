module FlexmlsApi
  module Models
    class Photo < Base

      def primary? 
        @attributes["Primary"] == true 
      end

    end
  end
end
