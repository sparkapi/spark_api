require 'date'
require 'time'

module SparkApi
  module Models
    class TourOfHome < Base
      extend Subresource

      self.element_name = "tourofhomes"
      
      def initialize(attributes={})
        # Transform the date strings
        unless attributes['Date'].nil?
          date = Date.parse(attributes['Date'])
          attributes['Date'] = date
          attributes['StartTime'] = Time.parse("#{date}T#{attributes['StartTime']}") unless attributes['StartTime'].nil?
          attributes['EndTime'] = Time.parse("#{date}T#{attributes['EndTime']}") unless attributes['EndTime'].nil?
        end
        super(attributes)
      end
      
    end
  end
end
