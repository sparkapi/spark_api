require 'date'
require 'time'

module SparkApi
  module Models
    class OpenHouse < Base
      extend Subresource

      self.element_name = "openhouses"
      
      def initialize(attributes={})
        self.class.parse_date_start_and_end_times attributes
        if attributes["Comments"].nil?
          attributes["Comments"] = ""
        end
        super(attributes)
      end
      
    end
  end
end
