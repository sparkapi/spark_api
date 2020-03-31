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
        unless attributes['Date'].nil? && attributes['Date'].empty?
          date = Date.strptime attributes['Date'], '%m/%d/%Y'
          ['StartTime','EndTime'].each do |time|
            next if attributes[time].nil? && attributes['Date'].empty?
            formatted_date = "#{attributes['Date']}T#{attributes[time]}"
            datetime = nil

            begin
              datetime = DateTime.strptime(formatted_date, '%m/%d/%YT%l:%M %P')
              dst_offset = 0
            rescue => ex
              ; # Do nothing; doesn't matter
            end

            unless datetime
              other_formats = ['%m/%d/%YT%H:%M%z', '%m/%d/%YT%H:%M:%S%z']
              other_formats.each_with_index do |format, i|
                begin
                  datetime = DateTime.strptime(formatted_date, format)
                  datetime = datetime.new_offset DateTime.now.offset
                  now = Time.now
                  dst_offset = now.dst? || now.zone == 'UTC' ? 0 : 1
                  break
                rescue => ex
                  next
                end
              end
            end

            # if we still don't have a valid time, raise an error
            unless datetime
              raise ArgumentError.new('invalid date')
            end
            
            

            attributes[time] = Time.local(datetime.year, datetime.month, datetime.day,
                                          datetime.hour + dst_offset, datetime.min, datetime.sec)
          end
          attributes['Date'] = date
        end
      end

    end
  end
end
