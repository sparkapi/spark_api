module SparkApi
  module Models
    class Contact < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name="contacts"

      def initialize(attributes={})
        has_many :saved_searches, :class => SavedSearch
        has_many :listing_carts, :class => ListingCart

        super(attributes)
      end

      def self.by_tag(tag_name, arguments={})
        collect(connection.get("#{path}/tags/#{tag_name}", arguments))
      end

      def self.tags(arguments={})
        connection.get("#{path}/tags", arguments)
      end

      def self.my(arguments={})
        new(connection.get('/my/contact', arguments).first)
      end

      def subscriptions
        @subscriptions ||= Subscription.get(:_filter => "RecipientId Eq '#{self.attributes['Id']}'")
      end
            
      def self.export(arguments={})
        collect(connection.get("/contacts/export", arguments))
      end

      def self.export_all(arguments={})
        collect(connection.get("/contacts/export/all", arguments))
      end

      def vow_account(arguments={})
        VowAccount.new(self.Id, connection.get("/contacts/#{self.Id}/portal", arguments).first)
      end

      # Notify the agent of contact creation via a Spark notification.
      def notify?; params_for_save[:Notify] == true end
      def notify=(notify_me)
        params_for_save[:Notify] = notify_me
      end
      
    end
  end
end
