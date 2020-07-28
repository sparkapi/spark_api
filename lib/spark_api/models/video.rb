module SparkApi
  module Models
    class Video < Base
      extend Subresource
      
      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end
      
      def private?
        attributes['Privacy'] == 'Private'
      end
      
      def public?
        attributes['Privacy'] == 'Public'
      end
      
      def automatic?
        attributes['Privacy'] == 'Automatic'
      end
    end
  end
end
