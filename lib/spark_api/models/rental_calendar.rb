module SparkApi
  module Models
    class RentalCalendar < Base
      extend Subresource
      self.element_name="rentalcalendar"

      def initialize(attributes={})
        # Transform the date strings
        unless attributes['StartDate'].nil?
          date = Date.parse(attributes['StartDate'])
          attributes['StartDate'] = date
        end
        unless attributes['EndDate'].nil?
          date = Date.parse(attributes['EndDate'])
          attributes['EndDate'] = date
        end        
        super(attributes)
      end

      def include_date? (day)
        day >= self.StartDate && day <= self.EndDate
      end

    end
  end
end
