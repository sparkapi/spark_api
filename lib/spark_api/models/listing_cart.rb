module SparkApi
  module Models
    class ListingCart < Base 
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="listingcarts"

      def ListingIds=(listing_ids)
        attributes["ListingIds"] = Array(listing_ids)
      end
      def Name=(name)
        attributes["Name"] = name
      end

      def add_listing(listing)
        id = listing.respond_to?(:Id) ? listing.Id : listing.to_s
        results = connection.post("#{self.class.path}/#{self.Id}", {"ListingIds" => [ listing ]})
        self.ListingCount = results.first["ListingCount"]
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

      def self.my(arguments={})
        collect(connection.get("/my/#{self.element_name}", arguments))
      end

      def self.portal(arguments={})
          collect(connection.get("/#{self.element_name}/portal", arguments))
      end

    end
  end
end
