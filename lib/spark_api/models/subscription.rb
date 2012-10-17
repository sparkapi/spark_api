module SparkApi
  module Models

    class Subscription < Base
      extend Finders
      include Concerns::Savable,
              Concerns::Destroyable

      self.element_name = "subscriptions"

      def subscribers
        return {} unless persisted?
        connection.get("#{path}/#{@attributes["Id"]}/subscribers")
      end

      [:subscribe, :unsubscribe].each do |action|
        method = (action == :subscribe ? :put : :delete)
        define_method(action) do |contact|
          return false unless persisted?
          self.errors = []
          begin
            connection.send(method, "#{path}/#{@attributes["Id"]}/subscribers/#{contact.Id}")
            true
          rescue BadResourceRequest, NotFound => e
            self.errors << { :code => e.code, :message => e.message }
            SparkApi.logger.error("Failed to #{verb} contact #{contact}: #{e.message}")
            false
          end
          false
        end
      end

    end

  end
end
