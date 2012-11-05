module SparkApi
  module Models
    class VowAccount < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

    end
  end
end
