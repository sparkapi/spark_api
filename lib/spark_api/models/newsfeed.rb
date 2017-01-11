module SparkApi
  module Models
    class Newsfeed < Base 
      
      extend Finders
      include Concerns::AsContact,
              Concerns::Destroyable,
              Concerns::Savable

      self.element_name = 'newsfeeds'

      def post_data
        attributes
      end

      def listing_search_role
        :public
      end
    end
  end
end
