module SparkApi
  module Models
    module MediaPrivacy
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
