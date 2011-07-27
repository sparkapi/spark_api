module FlexmlsApi
  module Models
    class SavedSearch < Base 
      extend Finders
      self.element_name="savedsearches"

      def self.provided()
        Class.new(self).tap do |provided|
          provided.element_name = '/savedsearches'
          provided.prefix = '/provided'
          FlexmlsApi.logger.info("#{self.name}.path: #{provided.path}")
        end
      end
    end
  end
end
