module SparkApi
  module Models
    class Newsfeed < Base 
      
      extend Finders
      include Concerns::Savable

      self.element_name = 'newsfeeds'

    end
  end
end
