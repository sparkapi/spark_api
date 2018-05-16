module SparkApi
  module Models
    class IncompleteListing < Base

      extend Finders

      include Concerns::Savable
      include Concerns::Destroyable

      self.element_name = "listings/incomplete"

    end
  end
end
