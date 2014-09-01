module SparkApi
  module Models
    class Video < Base
      extend Subresource
      self.element_name = 'videos'

      def branded?
        resource_type == 'branded'
      end

      def unbranded?
        resource_type == 'unbranded'
      end
    end
  end
end
