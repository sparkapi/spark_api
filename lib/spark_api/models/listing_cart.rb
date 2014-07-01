module SparkApi
  module Models
    class ListingCart < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="listingcarts"

      def initialize(attributes={})
        @contact_id = attributes.delete(:contact_id) if attributes[:contact_id]
        super(attributes)
      end

      def ListingIds=(listing_ids)
        attributes["ListingIds"] = Array(listing_ids)
      end
      def Name=(name)
        attributes["Name"] = name
      end

      def path
        if @contact_id
          "/contacts/#{@contact_id}/listingcarts"
        else
          super
        end
      end

      def add_listing(listing)
        ids = listing.respond_to?(:Id) ? listing.Id : listing
        results = connection.post("#{self.resource_uri}", {"ListingIds" => Array(ids)})
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
