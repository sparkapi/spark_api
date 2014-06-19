module SparkApi
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
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
        rescue NotFound => e
          # log and leave
          SparkApi.logger.error("Failed to save SharedListing #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        results = connection.post self.class.path, attributes, arguments
        result = results.first
        attributes['Id'] = result['Id']
        attributes['Mode'] = result['Mode']
        attributes['ResourceUri'] = result['ResourceUri']
        attributes['SharedUri'] = result['SharedUri']
        true
      end
    end
  end
end
