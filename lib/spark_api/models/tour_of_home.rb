require 'date'
require 'time'

module SparkApi
  module Models
    class TourOfHome < Base
      extend Subresource

      self.element_name = "tourofhomes"
      
      def initialize(attributes={})
        self.class.parse_date_start_and_end_times attributes
        super(attributes)
      end
      
    end
  end
end
