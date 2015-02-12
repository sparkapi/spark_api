module SparkApi
  module Models
    class Contact < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

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

      def saved_searches(arguments = {})
        @saved_searches ||= SavedSearch.collect(connection.get("/contacts/#{self.Id}/savedsearches", arguments))
      end

      def provided_searches(arguments = {})
        @provided_searches ||= SavedSearch.collect(connection.get("/contacts/#{self.Id}/provided/savedsearches", arguments))
      end

      def listing_carts(arguments = {})
        @listing_carts ||= ListingCart.collect(connection.get("/contacts/#{self.Id}/listingcarts", arguments))
      end

      def comments(arguments = {})
        @comments ||= Comment.collect(connection.get("/contacts/#{self.Id}/comments", arguments))
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
