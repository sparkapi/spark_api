module SparkApi
  module Models
    class VirtualTour < Base
      extend Subresource
      include Media
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="virtualtours"
      

      def branded? 
        attributes["Type"] == "branded"
      end

      def unbranded?
        attributes["Type"] == "unbranded"
      end

      def url
        attributes['Uri']
      end

      def description
        attributes['Name']
      end

      def display_image
        # Currently we have no universally good mechanism to get images for virtual tours
        return nil
      end
    end
  end
end
