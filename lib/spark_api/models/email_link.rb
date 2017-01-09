module SparkApi
  module Models
    class EmailLink < Base

      extend Finders

      self.prefix = "/flexmls/"
      self.element_name = "emaillinks"

      attr_accessor :template, :sort_id

      def filter
        "EmailLink Eq '#{id}'"
      end

      def listing_search_role
        :public
      end
    end
  end
end
