module SparkApi
  module Models
    class FloPlan < Base
      extend Subresource
      self.element_name = 'floplans'

      def initialize(attributes={})
        unless attributes['Images'].nil?
          images = []
          thumbnails = []
          attributes['Images'].each do |img|
            if img["Type"].include?('thumbnail')
              thumbnails << img
            else
              images << img
            end
          end
          attributes['Images'] = images
          attributes['Thumbnails'] = thumbnails
          super(attributes)
        end
      end
    end
  end
end
