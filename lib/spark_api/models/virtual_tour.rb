module SparkApi
  module Models
    class VirtualTour < Base
      extend Subresource
      include Media
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="virtualtours"
      

      def branded? 
        attributes["Type"] == "branded"
      end

      def unbranded?
        attributes["Type"] == "unbranded"
      end

      def url
        attributes['Uri']
      end

      def description
        attributes['Name']
      end

      def display_image
        begin
          response = Faraday::Connection.new.get(self.Uri) { |request| request.options.timeout = 20 }
          open_graph = OGP::OpenGraph.new(response.body)
          open_graph.image.url
        rescue
          return nil
        end
      end
    end
  end
end
