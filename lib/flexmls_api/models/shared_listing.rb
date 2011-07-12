module FlexmlsApi
  module Models
    class SharedListing < Base 
      extend Finders
      self.element_name="sharedlistings"
      
      def ListingIds=(listing_ids)
        attributes["ListingIds"] = Array(listing_ids)
      end
      def ViewId=(id)
        attributes["ViewId"] = id
      end
      def ReportId=(id)
        attributes["ReportId"] = id
      end
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
        rescue NotFound => e
          # log and leave
          FlexmlsApi.logger.error("Failed to save SharedListing #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        results = connection.post self.class.path, attributes, arguments
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        true
      end
    end
  end
end
