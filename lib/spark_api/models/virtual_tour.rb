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
    end
  end
end
