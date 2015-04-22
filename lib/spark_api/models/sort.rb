module SparkApi
  module Models
    class Sort < Base
      extend Finders

      self.element_name="/sorts"
      self.prefix="/searchtemplates"

    end
  end
end
