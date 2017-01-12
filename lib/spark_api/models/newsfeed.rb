module SparkApi
  module Models
    class Newsfeed < Base 
      
      extend Finders
      include Concerns::Destroyable,
              Concerns::Savable

      self.element_name = 'newsfeeds'

      def listing_search_role
        :public
      end
    end
  end
end
