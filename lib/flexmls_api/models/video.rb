module FlexmlsApi
  module Models
    class Video < Base
      extend Subresource
      self.element_name = 'videos'

      def branded?
        attributes['Type'] == 'branded'
      end

      def unbranded?
        attributes['Type'] == 'unbranded'
      end
    end
  end
end
