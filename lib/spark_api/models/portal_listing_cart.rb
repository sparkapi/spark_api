module SparkApi
  module Models

    class PortalListingCart < ListingCart

      def self.find(contact_id, *arguments)
        @contact_id = contact_id
        super(*arguments)
      end

    end
  end
end
