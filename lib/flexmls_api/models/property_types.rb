module FlexmlsApi
  class PropertyTypes < Model

    class << self 
      def get
        property_types = []
        resp = FlexmlsApi.client.get('/propertytypes')
        resp.each do |p|
          property_types.push(new(p))
        end
        property_types
      end
    end

  end
end
