module SparkApi
  module Models
    class Comment < Base
      include Concerns::Savable,
              Concerns::Destroyable
      self.element_name = "comments"
    end
  end
end
