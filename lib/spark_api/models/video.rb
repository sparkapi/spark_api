module SparkApi
  module Models
    class Video < Base
      extend Subresource
      include MediaPrivacy
      include Concerns::Savable,
              Concerns::Destroyable

      attr_accessor :update_path
      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end
      
      def self.path
        update_path
      end
      
    end
  end
end
