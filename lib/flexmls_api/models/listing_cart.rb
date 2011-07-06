module FlexmlsApi
  module Models
    class ListingCart < Base 
      extend Finders
      self.element_name="listingcarts"

      def ListingIds=(listing_ids)
        attributes["ListingIds"] = Array(listing_ids)
      end
      def Name=(name)
        attributes["Name"] = name
      end
      
      def remove_listing(listing)
        id = listing.respond_to?(:Id) ? listing.Id : listing.to_s
        results = connection.delete("#{self.class.path}/#{self.Id}/listings/#{id}")
        self.ListingCount = results.first["ListingCount"]
      end
      
      def self.for(listings,arguments={})
        keys = Array(listings).map { |l| l.respond_to?(:Id) ? l.Id : l.to_s }
        collect(connection.get("/#{self.element_name}/for/#{keys.join(",")}", arguments))
      end
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
        rescue NotFound => e
          # log and leave
          FlexmlsApi.logger.error("Failed to save contact #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        attributes['Id'].nil? ? create!(arguments) : update!(arguments)
      end
      
      def delete(args={})
        connection.delete("#{self.class.path}/#{self.Id}", args)
      end
      
      private 
      def create!(arguments={})
        results = connection.post self.class.path, {"ListingCarts" => [ attributes ]}, arguments
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        attributes['Id'] = parse_id(result['ResourceUri'])
        true
      end
      def update!(arguments={})
        results = connection.put "#{self.class.path}/#{self.Id}", {"ListingCarts" => [ {"Name" => attributes["Name"], "ListingIds" => attributes["ListingIds"]} ] }, arguments
        true
      end

    end
  end
end
