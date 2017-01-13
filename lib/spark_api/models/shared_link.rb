module SparkApi
  module Models
    class SharedLink < Base
      extend Finders

      attr_accessor :sort_id
      attr_writer :name

      self.element_name = "sharedlinks"

      def self.create(data)
        SharedLink.new SparkApi.client.post("#{path}/#{resource_type(data)}", data).first
      rescue SparkApi::BadResourceRequest
        false
      end

      def name
        if @name
          @name
        elsif respond_to?(:ListingCart) && self.ListingCart.respond_to?(:Name)
          self.ListingCart.Name
        elsif respond_to?(:SavedSearch) && self.SavedSearch.respond_to?(:Name)
          self.SavedSearch.Name
        end
      end

      def template
        if respond_to?(:SavedSearch) && self.SavedSearch.respond_to?(:template)
          self.SavedSearch.template
        end
      end

      def filter
        "SharedLink Eq '#{id}'"
      end

      def listing_search_role
        self.Mode.downcase.to_sym
      end

      private

      def self.resource_type(data)
        case data.keys[0].to_sym
          when :ListingIds; "listings"
          when :SearchId;   "search"
          when :CartId;     "cart"
        end
      end

    end
  end
end
