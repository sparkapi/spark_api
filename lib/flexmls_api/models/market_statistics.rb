module FlexmlsApi
  module Models
    class MarketStatistics < Model
    
      def self.absorption(parameters={})
        self.get('absorption',parameters)
      end
      def self.inventory(parameters={})
        self.get('inventory',parameters)
      end
      def self.price(parameters={})
        self.get('price',parameters)
      end
      def self.ratio(parameters={})
        self.get('ratio',parameters)
      end
      def self.dom(parameters={})
        self.get('dom',parameters)
      end
      def self.volume(parameters={})
        self.get('volume',parameters)
      end

      private 
      def self.get(stat_name, parameters={})
        instances = []
        resp = FlexmlsApi.client.get("/marketstatistics/#{stat_name}", parameters)
        new(resp[0])
      end
      
    end
  end
end
