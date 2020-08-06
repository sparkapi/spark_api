module SparkApi
  module Models
    class VirtualTour < Base
      extend Subresource
      include MediaPrivacy
      include Concerns::Savable,
              Concerns::Destroyable

      attr_accessor :update_path
      self.element_name="virtualtours"
      

      def branded? 
        attributes["Type"] == "branded"
      end

      def unbranded?
        attributes["Type"] == "unbranded"
      end

      def self.path
        update_path
      end
    end
  end
end
