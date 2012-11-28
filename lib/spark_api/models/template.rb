module SparkApi
  module Models

    # Email Templates
    class Template < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = "templates"

      def post_data; attributes end

    end

  end
end
