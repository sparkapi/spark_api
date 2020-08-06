module SparkApi
  module Models
    class VirtualTour < Base
      extend Subresource
      include MediaPrivacy
      include Concerns::Savable,
              Concerns::Destroyable
      self.element_name="virtualtours"
      

      def branded? 
        attributes["Type"] == "branded"
      end

      def unbranded?
        attributes["Type"] == "unbranded"
      end

    end
  end
end
