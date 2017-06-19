module SparkApi
  module Models
    class NewsFeedMeta < Base

      self.element_name = "newsfeeds/meta"

      def minimum_core_fields
        data['Subscriptions']['SavedSearches']['MinimumCoreFields']
      end

      def core_field_names
        fields = data['Subscriptions']['SavedSearches']['CoreSearchFields'].dup

        data['Subscriptions']['SavedSearches']['CoreStandardFields'].each do |field|
          fields << field[1]['Label']
        end

        fields
      end

      def core_fields
        fields = data['Subscriptions']['SavedSearches']['CoreSearchFields'].dup

        data['Subscriptions']['SavedSearches']['CoreStandardFields'].each do |field|
          fields << field.first
        end

        fields
      end

      private

      def data
        if attributes.empty?
          @data ||= connection.get(self.path).first
        else
          attributes
        end
      end

    end
  end
end
