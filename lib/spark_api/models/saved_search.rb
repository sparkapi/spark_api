module SparkApi
  module Models

    class SavedSearch < Base 
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      attr_accessor :newsfeeds

      self.element_name="savedsearches"

      def initialize(attributes={})
        @newsfeeds = nil
        super(attributes)
      end

      def self.provided()
        Class.new(self).tap do |provided|
          provided.element_name = '/savedsearches'
          provided.prefix = '/provided'
          def provided_search?
            true
          end
          def newsfeeds
            []
          end
          SparkApi.logger.info("#{self.name}.path: #{provided.path}")
        end
      end

      def self.tagged(tag, arguments={})
        collect(connection.get("/#{self.element_name}/tags/#{tag}", arguments))
      end

      # list contacts (private role)
      def contacts
        return [] unless persisted?
        results = connection.get("#{self.class.path}/#{@attributes["Id"]}")
        @attributes['ContactIds'] = results.first['ContactIds']
      end

      # attach/detach contact (private role)
      [:attach, :detach].each do |action|
        method = (action == :attach ? :put : :delete)
        define_method(action) do |contact|
          self.errors = []
          contact_id = contact.is_a?(Contact) ? contact.Id : contact
          begin
            connection.send(method, "#{self.class.path}/#{@attributes["Id"]}/contacts/#{contact_id}")
          rescue BadResourceRequest => e
            self.errors << { :code => e.code, :message => e.message }
            SparkApi.logger.warn("Failed to #{action} contact #{contact}: #{e.message}")
            return false
          rescue NotFound => e
            self.errors << { :code => e.code, :message => e.message }
            SparkApi.logger.error("Failed to #{action} contact #{contact}: #{e.message}")
            return false
          end
          update_contacts(action, contact_id)
          true
        end
      end

      def listings(args = {})
        arguments = {:_filter => self.Filter}.merge(args)
        @listings ||= Listing.collect(connection.get("/listings", arguments))
      end

      def newsfeeds
        if @newsfeeds.nil?
          response = SparkApi.client.get("/savedsearches/#{@attributes["Id"]}", _expand: "NewsFeeds").first["NewsFeeds"]
              # the response from the api is just a bunch of hashes, but we can turn them into Newsfeed instances
          @newsfeeds = response.map { |hash| Newsfeed.new(hash) }
        end
        @newsfeeds
      end

      def provided_search?
        false
      end

      def can_have_newsfeed?

        return false if provided_search? 
        return true  if has_active_newsfeed? || has_inactive_newsfeed?

        # Newsfeed restriction criteria for saved searches:
        # http://alpha.sparkplatform.com/docs/api_services/newsfeed/restrictions#criteria
        standard_fields = %w(BathsTotal BedsTotal City CountyOrParish ListPrice Location MlsStatus PostalCode PropertyType RoomsTotal State)

        number_of_filters = 0

        standard_fields.each do |field|
          number_of_filters += 1 if self.Filter.include? field
        end
        
        number_of_filters >= 3

      end

      def has_active_newsfeed?
        return false if provided_search? 

        if self.respond_to? "NewsFeedSubscriptionSummary"
          self.NewsFeedSubscriptionSummary['ActiveSubscription']
        else
          saved_search = SavedSearch.find( self.Id, {"_expand" => "NewsFeedSubscriptionSummary"})
          saved_search.NewsFeedSubscriptionSummary['ActiveSubscription']
        end
      end

      def has_inactive_newsfeed?
        return false if provided_search? 
       
        if self.respond_to? "NewsFeedSubscriptionSummary"
          !self.NewsFeedSubscriptionSummary['ActiveSubscription']
        else
          saved_search = SavedSearch.find( self.Id, {"_expand" => "NewsFeedSubscriptionSummary"})
          !saved_search.NewsFeedSubscriptionSummary['ActiveSubscription']
        end
      end

      private

      def resource_pluralized; "SavedSearches" end

      def update_contacts(method, contact_id)
        @attributes['ContactIds'] = [] if @attributes['ContactIds'].nil?
        case method
        when :attach
          @attributes['ContactIds'] << contact_id
        when :detach
          @attributes['ContactIds'].delete contact_id
        end
      end

    end

  end
end
