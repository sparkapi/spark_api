module SparkApi
  module Models
    class Video < Base
      extend Subresource
      include MediaPrivacy
      include Concerns::Savable,
              Concerns::Destroyable
      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end
      
      
    end
  end
end
