module SparkApi
  module Models
    module Subresource 
    
      def build_subclass
        Class.new(self)
      end

      def find_by_listing_key(key, arguments={})
        collect(connection.get("/listings/#{key}#{self.path}", arguments))
      end
      
      def find_by_id(id, parent_id, arguments={})
        collect(connection.get("/listings/#{parent_id}#{self.path}/#{id}", arguments)).first
      end
      
      def parse_date_start_and_end_times(attributes)
        # Transform the date strings
        unless attributes['Date'].nil?
          date = Date.strptime attributes['Date'], '%m/%d/%Y'
          ['StartTime','EndTime'].each do |time|
            next if attributes[time].nil?
            format = '%m/%d/%YT%H:%M%z'
            if attributes[time].split(':').size > 3
              format = '%m/%d/%YT%H:%M:%S%z'
            end
            formatted_date = "#{attributes['Date']}T#{attributes[time]} FORMAT: #{format}"
            datetime = DateTime.strptime(formatted_date, format)
            datetime = datetime.new_offset DateTime.now.offset 
            attributes[time] = Time.local(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.min,
                                          datetime.sec)
          end
          attributes['Date'] = date
        end
      end
      
    end
  end
end
