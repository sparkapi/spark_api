module SparkApi
  module Models
    class NewsFeedMeta < Base

      attr_accessor :data

      self.element_name = "newsfeeds/meta"

      def initialize
        super
        @data = connection.get(self.path).first
      end

      def minimum_core_fields
        @data['Subscriptions']['SavedSearches']['MinimumCoreFields']
      end

      def core_field_names
        fields = @data['Subscriptions']['SavedSearches']['CoreSearchFields']

        @data['Subscriptions']['SavedSearches']['CoreStandardFields'].each do |field|
          fields << field[1]['Label']
        end

        fields
      end

      def core_fields
        fields = @data['Subscriptions']['SavedSearches']['CoreSearchFields']

        @data['Subscriptions']['SavedSearches']['CoreStandardFields'].each do |field|
          fields << field.first
        end

        fields
      end

    end
  end
end
