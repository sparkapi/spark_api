module SparkApi
  module Models
    class VirtualTour < Base
      extend Subresource
      self.element_name = 'virtualtours'


      def branded?
        resource_type == 'branded'
      end

      def unbranded?
        resource_type == 'unbranded'
      end

    end
  end
end
