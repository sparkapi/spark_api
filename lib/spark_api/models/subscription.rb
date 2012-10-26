module SparkApi
  module Models

    class Subscription < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = "subscriptions"

      # list subscribers (private role)
      def subscribers
        return {} unless persisted?
        results = connection.get("#{self.class.path}/#{@attributes["Id"]}/subscribers")
        @attributes['RecipientIds'] = results.first['RecipientIds']
        results
      end

      # subscribe/unsubscribe contact (private role)
      [:subscribe, :unsubscribe].each do |action|
        method = (action == :subscribe ? :put : :delete)
        define_method(action) do |contact|
          return false unless persisted?
          self.errors = []
          contact_id = contact.is_a?(Contact) ? contact.Id : contact
          begin
            connection.send(method, "#{self.class.path}/#{@attributes["Id"]}/subscribers/#{contact_id}")
          rescue BadResourceRequest, NotFound => e
            self.errors << { :code => e.code, :message => e.message }
            SparkApi.logger.error("Failed to #{action} contact #{contact}: #{e.message}")
            return false
          end
          update_recipients(action, contact_id)
          true
        end
      end

      private

      def update_recipients(method, contact_id)
        case method
        when :subscribe
          @attributes['RecipientIds'] << contact_id
        when :unsubscribe
          @attributes['RecipientIds'].delete contact_id
        end
      end

    end

  end
end
