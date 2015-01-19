module SparkApi
  module Models
    class QuickSearch < Base 
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = "searchtemplates/quicksearches"

      def fields(args = {})
        arguments = {:_expand => "Fields"}.merge(args)
        @fields ||= connection.get("/searchtemplates/quicksearches/#{self.Id}", arguments).first["Fields"]
      end

    end
  end
end
