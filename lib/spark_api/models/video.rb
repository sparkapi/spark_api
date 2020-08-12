module SparkApi
  module Models
    class Video < Base
      extend Subresource
      include Media
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end

      def url
        attributes['ObjectHtml']
      end

      def description
        attributes['Name']
      end
      
    end
  end
end
