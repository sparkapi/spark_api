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

      private

      def resource_pluralized; "SavedSearches" end

    end

  end
end
