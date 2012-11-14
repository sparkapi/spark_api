module SparkApi
  module Models
    class Contact < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      attr_accessor :saved_searches, :listing_carts

      self.element_name="contacts"

      def self.by_tag(tag_name, arguments={})
        collect(connection.get("#{path}/tags/#{tag_name}", arguments))
      end

      def self.tags(arguments={})
        connection.get("#{path}/tags", arguments)
      end

      def self.my(arguments={})
        new(connection.get('/my/contact', arguments).first)
      end
            
      def self.export(arguments={})
        collect(connection.get("/contacts/export", arguments))
      end

      def self.export_all(arguments={})
        collect(connection.get("/contacts/export/all", arguments))
      end

      # Notify the agent of contact creation via a Spark notification.
      def notify?; params_for_save[:Notify] == true end
      def notify=(notify_me)
        params_for_save[:Notify] = notify_me
      end

      def saved_searches
        @saved_searches ||= SavedSearch.collect(connection.get("/contacts/#{self.Id}/savedsearches"))
      end

      def listing_carts
        @listing_carts ||= SavedSearch.collect(connection.get("/contacts/#{self.Id}/listingcarts"))
      end

      def subscriptions
        @subscriptions ||= Subscription.get(:_filter => "RecipientId Eq '#{self.attributes['Id']}'")
      end

      def comments
        @comments ||= Comment.collect(connection.get("/contacts/#{self.Id}/comments"))
      end
      def comment(body)
        comment = Comment.new({ :Comment => body })
        comment.parent = self
        comment.save
        comment
      end

      def vow_account(arguments={})
        return @vow_account if @vow_account
        begin
          @vow_account = VowAccount.new(connection.get("/contacts/#{self.Id}/portal", arguments).first)
          @vow_account.parent = self
          @vow_account
        rescue NotFound
          nil
        end
      end
      
    end
  end
end
