module SparkApi
  module Models

    class SavedSearch < Base 
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="savedsearches"

      def self.provided()
        Class.new(self).tap do |provided|
          provided.element_name = '/savedsearches'
          provided.prefix = '/provided'
          SparkApi.logger.info("#{self.name}.path: #{provided.path}")
        end
      end

      def self.tagged(tag, arguments={})
        collect(connection.get("/#{self.element_name}/tags/#{tag}", arguments))
      end

      def favorite?
        @attributes["Tags"] && @attributes["Tags"].include?( "Favorites")
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
        arguments = {:_filter => "SavedSearch Eq '#{self.Id}'"}
        arguments.merge!(:RequestMode => 'permissive') if Provided?
        @listings ||= Listing.collect(connection.get("/listings", arguments.merge(args)))
      end

      def newsfeeds
        @newsfeeds ||=  if attributes.key?("NewsFeeds")
                          Newsfeed.collect(attributes["NewsFeeds"])
                        else
                          Newsfeed.collect(connection.get("#{self.class.path}/#{@attributes["Id"]}", 
                            :_expand => "NewsFeeds").first["NewsFeeds"])
                        end
      end

      def has_active_newsfeed?
        if self.respond_to? "NewsFeedSubscriptionSummary"
          self.NewsFeedSubscriptionSummary['ActiveSubscription']
        else
          search = connection.get "#{self.class.path}/#{@attributes['Id']}", 
            {"_expand" => "NewsFeedSubscriptionSummary"}
          search.first["NewsFeedSubscriptionSummary"]["ActiveSubscription"]
        end
      end

      def has_inactive_newsfeed?
        if self.respond_to?("NewsFeeds") && self.respond_to?("NewsFeedSubscriptionSummary")
          self.NewsFeeds.any? && !self.NewsFeedSubscriptionSummary['ActiveSubscription']
        else
          search = connection.get("#{self.class.path}/#{@attributes['Id']}", 
            {"_expand" => "NewsFeedSubscriptionSummary, NewsFeeds"}).first
          search["NewsFeeds"].any? && !search["NewsFeedSubscriptionSummary"]["ActiveSubscription"]
        end
      end

      def listing_search_role
        :public if path =~ /contact/
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
