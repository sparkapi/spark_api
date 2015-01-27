module SparkApi
  module Models
    class Newsfeed < Base 
      
      extend Finders

      self.element_name = 'newsfeeds'

      def update!(arguments={})
        connection.put( "/newsfeeds/#{self.Id}", arguments ).first
      end

    end
  end
end
