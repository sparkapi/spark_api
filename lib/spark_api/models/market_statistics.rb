module SparkApi
  module Models
    class MarketStatistics < Base
      self.element_name="marketstatistics"
      
      def self.absorption(parameters={})
        self.stat('absorption',parameters)
      end
      def self.inventory(parameters={})
        self.stat('inventory',parameters)
      end
      def self.price(parameters={})
        self.stat('price',parameters)
      end
      def self.ratio(parameters={})
        self.stat('ratio',parameters)
      end
      def self.dom(parameters={})
        self.stat('dom',parameters)
      end
      def self.volume(parameters={})
        self.stat('volume',parameters)
      end

      private 
      def self.stat(stat_name, parameters={})
        resp = connection.get("#{path}/#{stat_name}", parameters)
        new(resp.first)
      end
      
    end
  end
end
