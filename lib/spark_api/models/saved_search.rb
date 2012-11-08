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
          return false unless persisted?
          self.errors = []
          contact_id = contact.is_a?(Contact) ? contact.Id : contact
          begin
            connection.send(method, "#{self.class.path}/#{@attributes["Id"]}/contacts/#{contact_id}")
          rescue BadResourceRequest, NotFound => e
            self.errors << { :code => e.code, :message => e.message }
            SparkApi.logger.error("Failed to #{action} contact #{contact}: #{e.message}")
            return false
          end
          update_contacts(action, contact_id)
          true
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
